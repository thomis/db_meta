module DbMeta
  module Oracle
    class Sequence < Base
      register_type("SEQUENCE")

      attr_reader :min_value, :max_value, :increment_by, :cycle_flag, :order_flag, :cache_size, :last_number

      def fetch(args = {})
        connection_class = args[:connection_class] || Connection
        connection = connection_class.instance.get
        cursor = connection.exec("select to_char(min_value), to_char(max_value), to_char(increment_by), cycle_flag, order_flag, to_char(cache_size), to_char(last_number) from user_sequences where sequence_name = '#{@name}'")
        while (row = cursor.fetch)
          @min_value = row[0].to_i
          @max_value = row[1].to_i
          @increment_by = row[2].to_i
          @cycle_flag = row[3].to_s
          @order_flag = row[4].to_s
          @cache_size = row[5].to_i
          @last_number = row[6].to_i
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        buffer = [block(@name)]
        buffer << "CREATE SEQUENCE #{@name}"
        buffer << "  START WITH #{@last_number}"
        buffer << "  MAXVALUE #{@max_value}"
        buffer << "  MINVALUE #{@min_value}"
        buffer << ((@cycle_flag == "N") ? "  NOCYCLE" : "  CYCLE")
        buffer << ((@cache_size == 0) ? "  NOCACHE" : "  CACHE #{@cache_size}")
        buffer << ((@order_flag == "N") ? "  NOORDER" : "  ORDER")
        buffer << ";"
        buffer << nil
        buffer.join("\n")
      end
    end
  end
end
