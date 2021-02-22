module DbMeta
  module Oracle
    class Objects
      include DbMeta::Oracle::Helper
      extend DbMeta::Oracle::Helper

      attr_reader :summary_system_object

      def initialize
        @data = Hash.new { |h, type| h[type] = {} }
        @worker_queue = ::Queue.new
        @types_with_object_status_default = []

        @summary = Hash.new { |h, type| h[type] = 0 }
        @summary_system_object = Hash.new { |h, type| h[type] = 0 }
        @invalids = Hash.new { |h, type| h[type] = [] }
      end

      def <<(object)
        @data[object.type][object.name] = object
        @worker_queue << object

        @summary[object.type] += 1
        @summary_system_object[object.type] += 1 if object.system_object?
        @invalids[object.type] << object if [:invalid, :disabled].include?(object.status)
      end

      def fetch(args = {})
        # fetch details in parallel
        # number of threads = physical connections / 2 to prevent application locking
        worker = (1..Connection.instance.worker / 2).map {
          Thread.new do
            while (object = @worker_queue.pop(true))
              Log.info(" - #{object.type} - #{object.name}")
              object.fetch
            end
          rescue ThreadError
          end
        }
        worker.map(&:join) # wait until all are done
      end

      def detect_system_objects
        Log.info("Detecting system objects...")

        # detect materialized view tables
        @data["MATERIALZIED VIEW"].values.each do |object|
          table = @data["TABLE"][object.name]
          next unless table
          table.system_object = true
        end

        @data["QUEUE"].values.each do |object|
          table = @data["TABLE"][object.queue_table]
          next unless table
          table.system_object = true
        end
      end

      def merge_synonyms
        Log.info("Merging synonyms...")
        synonym_collection = SynonymCollection.new(type: "SYNONYM", name: "ALL")

        @data["SYNONYM"].values.each do |object|
          synonym_collection << object
        end

        return if synonym_collection.empty?

        self << synonym_collection
        @summary["SYNONYM"] -= 1 # no need to count collection object
      end

      def merge_grants
        Log.info("Merging grants...")
        grant_collection = GrantCollection.new(type: "GRANT", name: "ALL")

        @data["GRANT"].values.sort_by { |o| o.sort_value }.each do |object|
          grant_collection << object
        end

        return if grant_collection.empty?

        self << grant_collection
        @summary["GRANT"] -= 1 # no need to count collection object
      end

      def embed_indexes
        Log.info("Embedding indexes...")

        @data["INDEX"].values.each do |object|
          next unless @data["TABLE"][object.table_name]
          @data["TABLE"][object.table_name].add_object(object)
        end
      end

      def embed_constraints
        Log.info("Embedding constraints...")

        @data["CONSTRAINT"].values.each do |constraint|
          next unless @data["TABLE"][constraint.table_name]
          @data["TABLE"][constraint.table_name].add_object(constraint)
        end
      end

      def embed_triggers
        Log.info("Embedding triggers...")

        @data["TRIGGER"].values.each do |object|
          table_object = @data["TABLE"][object.table_name]

          if table_object
            table_object.add_object(object)
          else
            # if there is no table relation, just extract as default
            object.extract_type = :default
          end
        end
      end

      def merge_constraints
        Log.info("Merging constraints...")
        constraint_collection = ConstraintCollection.new(type: "CONSTRAINT", name: "ALL FOREIGN KEYS")

        @data["CONSTRAINT"].values.each do |object|
          next unless object.extract_type == :merged
          constraint_collection << object
        end

        return if constraint_collection.empty?

        self << constraint_collection
        @summary["CONSTRAINT"] -= 1 # no need to count collection object
      end

      def handle_table_data(args)
        Log.info("Handling table data...")

        @exclude_data = args[:exclude_data] if args[:exclude_data]
        @include_data = args[:include_data] if args[:include_data]

        tables = []
        @data["TABLE"].values.each do |table|
          next if table.system_object?
          if @exclude_data
            next if table.name&.match?(@exclude_data)
          end
          if @include_data
            next unless table.name&.match?(@include_data)
          end
          tables << table
        end

        self << TableDataCollection.new(name: "ALL CORE DATA", type: "DATA", tables: tables)
        @summary["DATA"] -= 1 # no need to count DATA object
      end

      def default_each
        @data.keys.sort_by { |type| type_sequence(type) }.each do |type|
          @data[type].keys.sort.each do |name|
            object = @data[type][name]
            next if object.system_object?
            next unless object.extract_type == :default
            yield(object)
          end
        end
      end

      def reverse_default_each
        @data.keys.sort_by { |type| type_sequence(type) }.reverse_each do |type|
          @data[type].keys.sort.each do |name|
            object = @data[type][name]
            next if object.system_object?
            next unless object.extract_type == :default
            yield object
          end
        end
      end

      def summary_each
        @summary.each_pair do |type, count|
          yield type, count
        end
      end

      def invalids?
        @invalids.keys.size > 0
      end

      def invalid_each
        @invalids.each_pair do |type, objects|
          yield type, objects
        end
      end

      def self.all
        objects = []

        # get all objects as a hash containing name, type, status
        items = []
        types = []
        connection = Connection.instance.get
        cursor = connection.exec(OBJECT_QUERY)
        cursor.fetch_hash do |item|
          items << item
          types << item["OBJECT_TYPE"]
        end
        cursor.close

        # sort items and make an object instance
        items.sort_by { |i| [type_sequence(i["OBJECT_TYPE"]), i["OBJECT_NAME"]] }.each do |item|
          objects << Base.from_type(item)
        end

        Log.info("Objects: #{items.size}, Object Types: #{types.uniq.size}")

        objects
      ensure
        connection&.logoff # closes logical connection
      end
    end
  end
end
