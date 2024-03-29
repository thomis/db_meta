module DbMeta
  module Oracle
    class TableDataCollection
      include DbMeta::Oracle::Helper

      attr_reader :name, :type, :status, :extract_type, :collection

      def initialize(args = {})
        @name = args[:name]
        @type = args[:type]
        @status = :valid
        @extract_type = :default
        @tables = args[:tables]
      end

      def extract(args = {})
        buffer = [block(@name)]
        buffer << "set define off;"
        buffer << "set sqlblanklines on;"
        buffer << nil

        connection = Connection.instance.get

        @tables.each do |table|
          Log.info("Extracting data from #{table.name}...")

          buffer << block(table.name, 40)

          name_type_map = {}
          table.columns.each do |column|
            name_type_map[column.name] = column.type
          end

          statement = "select * from #{table.name} #{table.get_core_data_where_clause}"
          cursor = connection.exec(statement)
          cursor.fetch_hash do |item|
            buffer << "insert into #{table.name}(#{item.keys.join(", ")}) values(#{format_values(name_type_map, item)});"
          end
          cursor.close
          buffer << nil
        end

        buffer << "commit;"
        buffer << nil

        buffer.join("\n")
      ensure
        connection.logoff
      end

      def ddl_drop
        "-- will automatically be dropped with table object"
      end

      def system_object?
        false
      end

      private

      def format_values(name_type_map, item)
        buffer = []

        item.each_pair do |key, value|
          if value.nil?
            buffer << "NULL"
            next
          end

          buffer << case name_type_map[key]
          when /varchar|char/i
            "'#{value.gsub("'", "''")}'"
          when /clob/i
            m = []
            d = value.read
            d.chars.each_slice(2000).map(&:join).each do |item|
              m << "to_clob('#{item.gsub("'", "''").gsub(";", "' || CHR(59) || '")}')"
            end
            m.join(" || ")
          when /date/i
            "to_date('#{value.strftime("%Y-%m-%d %H:%M:%S")}','YYYY-MM-DD HH24:MI:SS')"
          when /timestamp/i
            "to_timezone('#{value.strftime("%Y-%m-%d %H:%M:%S %Z")}','YYYY-MM-DD HH24:MI:SS.FF TZD')"
          when /raw/i
            "'#{value}'"
          else
            value.to_s
          end
        end

        buffer.join(", ")
      end
    end
  end
end
