module DbMeta
  module Oracle
    class DatabaseLink < Base
      register_type("DATABASE LINK")

      attr_reader :username, :password, :host

      def fetch(args = {})
        connection = Connection.instance.get
        cursor = connection.exec("select username, password, host from user_db_links where db_link = '#{@name}'")
        while (row = cursor.fetch)
          @username = row[0].to_s
          @password = row[1].to_s
          @host = row[2].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        buffer = []
        buffer << "CREATE DATABASE LINK #{@name}"
        buffer << " CONNECT TO #{@username}"
        buffer << " IDENTIFIED BY :1"
        buffer << " USING '#{@host}';"
        buffer << nil
        buffer.join("\n")
      end
    end
  end
end
