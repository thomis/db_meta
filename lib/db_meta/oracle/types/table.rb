module DbMeta
  module Oracle
    class Table < Base
      register_type('TABLE')

      attr_reader :columns, :temporary, :cache, :iot_type, :duration

      def initialize(args={})
        super(args)

        @comment = nil # table level comment

        @comment = nil
        @columns = []
        @indexes = []
        @constraints = []
        @triggers = []
      end

      def add_object(object)
        @indexes << object if object.type == 'INDEX'
        @constraints << object if object.type == 'CONSTRAINT'
        @triggers << object if object.type == 'TRIGGER'
      end

      def fetch
        @comment = Comment.find(type: 'TABLE', name: @name)
        @columns = Column.all(object_name: @name)

        connection = Connection.instance.get
        cursor = connection.exec("select temporary, cache, iot_type, duration from user_tables where table_name = '#{@name}'")
        while row = cursor.fetch()
          @temporary = row[0].to_s.strip == 'Y' ? 'GLOBAL TEMPORARY' : nil
          @cache = row[1].to_s.strip == 'Y' ? 'CACHE' : 'NOCACHE'
          @iot_type = row[2].to_s
          @duration = row[3].to_s
        end
        cursor.close

      rescue
        connection.logoff
      end


      def extract(args={})
        buffer = [block(@name)]
        buffer << "CREATE#{" #{@temporary}" if @temporary} TABLE #{@name}"
        buffer << '('

        # add columns
        @columns.each_with_index do |c, index|
          buffer << "  #{c.extract}#{',' if index+1 < @columns.size}"
        end

        # Primary key definition must be here for IOT tables
        if @iot_type == 'IOT'
          constraint = @constraints.select{ |c| c.constraint_type == 'PRIMARY KEY'}[0]
          buffer[-1] += ','
          buffer << "  CONSTRAINT #{constraint.name}"
          buffer << "  PRIMARY KEY (#{constraint.columns.join(', ')})"
          buffer << "  ENABLE VALIDATE"
        end

        buffer << ')'
        buffer << translate_duration if @duration.size > 0
        buffer << @cache if @temporary
        buffer << "ORGANIZATION INDEX" if @iot_type == "IOT"
        buffer[-1] += ';'
        buffer << nil

        # table comments
        if @comment
          buffer << "COMMENT ON TABLE #{@name} IS '#{@comment.text("'","''")}';"
        end

        # table column comments
        @columns.each do |column|
          next if column.comment.size == 0
          buffer << "COMMENT ON COLUMN #{@name}.#{column.name} IS '#{column.comment.gsub("'","''")}';"
        end

        # indexes
        if @indexes.size > 0
          buffer << block("Indexes", 40)
          @indexes.each do |index|
            line = ""
            line << "-- System Index: " if index.system_object? || @iot_type == "IOT"
            line << index.extract(args)
            buffer << line
          end
          buffer << nil
        end

        # constaints
        if @constraints.size > 0
          buffer << block("Constraints", 40)
          @constraints.sort_by{ |c| [ Constraint.sort_value(c.constraint_type), c.name] }.each do |constraint|
            buffer << constraint.extract(args.merge({comment: (constraint.constraint_type == 'FOREIGN KEY')}))
          end
        end

        # triggers
        if @triggers.size > 0
          buffer << block("Triggers", 40)
          buffer << @triggers.map{ |o| o.extract(args) }.join("\n")
          buffer << nil
        end

        buffer.join("\n")
      end

      def ddl_drop
        "DROP #{@type} #{@name} CASCADE CONSTRAINTS PURGE;"
      end

      def system_object?
        is_system_object = super
        return is_system_object if is_system_object

       # check for tables created based on materialized views
        n = 0
        connection = Connection.instance.get
        cursor = connection.exec("select count(*) as n from user_mviews where mview_name = '#{@name}'")
        cursor.fetch_hash do |item|
          n = item['N']
        end
        cursor.close

        return n == 1
      ensure
        connection.logoff if connection
      end

      def get_core_data_where_clause(id=1000000)
        buffer = []
        @constraints.each do |constraint|
          if constraint.constraint_type == 'PRIMARY KEY'
            constraint.columns.each do |column|
              buffer << "#{column} < #{id}"
            end
          end
        end

        return '' if buffer.size == 0
        buffer.insert(0, 'where')
        buffer.join(' ')
      end

      private

      def translate_duration
        case @duration
          when "SYS$TRANSACTION"
            return "ON COMMIT DELETE ROWS"
          when "SYS$SESSION"
            return "ON COMMIT PRESERVE ROWS"
        else
          return "-- table duration definition [#{@duration}] is unknown and may need code adaptations"
        end
      end

    end
  end
end
