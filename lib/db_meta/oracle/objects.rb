module DbMeta
  module Oracle
    class Objects
      include DbMeta::Oracle::Helper
      extend DbMeta::Oracle::Helper

      def initialize
        @data = Hash.new{ |h, type|  h[type] = {} }
        @worker_queue = Queue.new
        @types_with_object_status_default = []

        @summary = Hash.new{ |h, type| h[type] = 0 }
        @invalids = Hash.new{ |h, type| h[type] = [] }
      end

      def <<(object)
        @data[object.type][object.name] = object
        @worker_queue << object

        @invalids[object.type] << object if [:invalid, :disabled].include?(object.status)

        @summary[object.type] += 1
        @invalids[object.type] << object if [:invalid, :disabled].include?(object.status)
      end

      def fetch(args={})
        # fetch details in parallel
        # start as many worker threads as max physical connections
        worker = (1..Connection.instance.worker).map do
          Thread.new do
            begin
              while object = @worker_queue.pop(true)
                Log.info(" - #{object.type} - #{object.name}")
                object.fetch
              end
            rescue ThreadError
            end
          end
        end
        worker.map(&:join) # wait until all are done
      end

      def merge_synonyms
        synonym_collection = SynonymCollection.new(type: 'SYNONYM', name: 'ALL')

        @data['SYNONYM'].values.each do |object|
          synonym_collection << object
        end

        self << synonym_collection unless synonym_collection.empty?
      end

      def default_each
        @data.keys.sort_by{ |type| type_sequence(type) }.each do |type|
          @data[type].keys.sort.each do |name|
            object = @data[type][name]
            next unless object.extract_type == :default
            yield(object)
          end
        end
      end

      def reverse_default_each
        @data.keys.sort_by{ |type| type_sequence(type) }.reverse_each do |type|
          @data[type].keys.sort.each do |name|
            object = @data[type][name]
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

          #next unless item['OBJECT_TYPE'] == 'SEQUENCE'

          items << item
          types << item['OBJECT_TYPE']
        end
        cursor.close

        # sort items and make an object instance
        items.sort_by{ |i| [ type_sequence(i['OBJECT_TYPE']), i['OBJECT_NAME']]}.each do |item|
          objects << Base.from_type(item)
        end

        Log.info("Objects: #{items.size}, Object Types: #{types.uniq.size}")

        objects
      ensure
        connection.logoff # closes logical connection
      end

    end
  end
end
