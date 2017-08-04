module DbMeta
  module Oracle
    class Table < Base
      register_type('TABLE')

      attr_reader :columns, :temporary, :cache, :iot_type, :duration

      def initialize(args={})
        super(args)

        @comment = nil # table level comment
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
        buffer = []
        buffer << "CREATE#{" #{@temporary}" if @temporary} TABLE #{@name}"
        buffer << '('

        # add columns
        @columns.each_with_index do |c, index|
          buffer << "  #{c.extract}#{',' if index+1 < @columns.size}"
        end

        # Primary key definition must be here for IOT tables
        # to do...

        buffer << ')'
        buffer << translate_duration if @duration.size > 0
        buffer << @cache if @temporary
        buffer << "ORGANIZATION INDEX" if @iot_type == "IOT"
        buffer << ';'
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

        buffer.join("\n")
      end

      def ddl_drop
        "DROP #{@type} #{@name} CASCADE CONSTRAINTS PURGE;"
      end

      private

      def translate_duration
        case @duration
          when "SYS$TRANSACTION"
            return "ON COMMIT DELETE ROWS"
          when "SYS$SESSION"
            return "ON COMMIT PRESERVE ROWS"
        else
          return "-- table duration definition [#{@duration}] is unknown and needs maybe code change"
        end
      end

    end
  end
end
