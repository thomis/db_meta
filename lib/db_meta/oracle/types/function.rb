module DbMeta
  module Oracle
    class Function < Base
      register_type("FUNCTION")

      attr_reader :source

      def fetch
        @source = ""
        connection = Connection.instance.get
        cursor = connection.exec("select text from user_source where type = 'FUNCTION' and name = '#{@name}' order by line")
        while (row = cursor.fetch)
          @source << row[0].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        buffer = [block(@name)]
        buffer << "create or replace #{@source.strip}"
        buffer << "/"
        buffer << nil
        buffer.join("\n")
      end
    end
  end
end
