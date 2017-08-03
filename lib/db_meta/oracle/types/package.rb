module DbMeta
  module Oracle
    class Package < Base
      register_type('PACKAGE')

      attr_reader :header, :body

      def fetch
        @header = ""
        cursor = Connection.instance.get.exec("select text from user_source where type = 'PACKAGE' and name = '#{@name}' order by line")
        while row = cursor.fetch()
          @header << row[0].to_s
        end
        cursor.close

        @body = ""
        connection = Connection.instance.get
        cursor = connection.exec("select text from user_source where type = 'PACKAGE BODY' and name = '#{@name}' order by line")
        while row = cursor.fetch()
          @body << row[0].to_s
        end
        cursor.close
      ensure
          connection.logoff
      end

      def extract(args={})
        buffer = []
        buffer << @header.strip
        buffer << '/'
        buffer << nil

        buffer << @body.strip
        buffer << '/'
        buffer << nil

        buffer.join("\n")
      end

    end
  end
end
