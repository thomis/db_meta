require 'singleton'

module DbMeta
  module Oracle
    class Connection
      include Singleton

      attr_reader :connection
      attr_accessor :username, :password, :database_instance


      def set(username, password, database_instance)
        @username = username
        @password = password
        @database_instance = database_instance
      end

      def get
        return @connection if @connection
        @connection = ::OCI8.new(@username, @password, @database_instance)
        Log.info("Connected to #{@username}@#{@database_instance}")
        @connection
      end

      def disconnect
        return unless @connection
        @connection.logoff
        Log.info("Logged off from #{@username}@#{@database_instance}")
        @connection = nil
      end
    end
  end
end
