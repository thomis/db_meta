module DbMeta
  module Oracle
    class Procedure < Base
      register_type('PROCEDURE')

      attr_reader :source

      def fetch
        @source = ""
        connection = Connection.instance.get
        cursor = connection.exec("select text from user_source where type = 'PROCEDURE' and name = '#{@name}' order by line")
        while row = cursor.fetch()
          @source << row[0].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args={})
        buffer = []
        buffer << @source.strip
        buffer << '/'
        buffer << nil
        buffer.join("\n")
      end

    end
  end
end
