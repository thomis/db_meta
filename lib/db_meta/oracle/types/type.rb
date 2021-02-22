module DbMeta
  module Oracle
    class Type < Base
      register_type("TYPE")

      def fetch
        @source = ""
        @body = ""
        connection = Connection.instance.get
        cursor = connection.exec("select text from user_source where type = 'TYPE' and name = '#{@name}' order by line")
        while (row = cursor.fetch)
          @source << row[0].to_s
        end
        cursor.close

        # check for type body
        cursor = connection.exec("select text from user_source where type = 'TYPE BODY' and name = '#{@name}' order by line")
        while (row = cursor.fetch)
          @body << row[0].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        buffer = [block(@name)]
        buffer << "CREATE OR REPLACE #{@source.strip}"
        buffer << "/"
        buffer << nil
        if @body.size > 0
          buffer << "CREATE OR REPLACE #{@body.strip}"
          buffer << "/"
          buffer << nil
        end
        buffer.join("\n")
      end
    end
  end
end
