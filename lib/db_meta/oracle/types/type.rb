module DbMeta
  module Oracle
    class Type < Base
      register_type('TYPE')

      def fetch
        @source = ""
        connection = Connection.instance.get
        cursor = connection.exec("select text from user_source where type = 'TYPE' and name = '#{@name}' order by line")
        while row = cursor.fetch()
          @source << row[0].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args={})
        buffer = [block(@name)]
        buffer << @source.strip
        buffer << '/'
        buffer << nil
        buffer.join("\n")
      end

    end
  end
end
