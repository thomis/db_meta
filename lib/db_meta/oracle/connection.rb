require "singleton"

module DbMeta
  module Oracle
    class Connection
      include Singleton

      attr_accessor :username, :password, :database_instance
      attr_reader :pool
      attr_reader :worker

      def set(username, password, database_instance, worker)
        @username = username
        @password = password
        @database_instance = database_instance
        @worker = worker
      end

      def get
        unless @pool
          # create connection pool
          @pool = ::OCI8::ConnectionPool.new(1, @worker, 1, @username, @password, @database_instance)
          Log.info("Connected to #{@username}@#{@database_instance}")
        end

        # create and return logical connection. It creates physical connection as needed.
        ::OCI8.new(@username, @password, @pool)
      end

      def disconnect
        return unless @pool
        @pool.destroy
        Log.info("Logged off from #{@username}@#{@database_instance}")
        @pool = nil
      end
    end
  end
end
