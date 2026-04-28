require "singleton"

module DbMeta
  module Oracle
    class Connection
      include Singleton

      THREAD_KEY = :db_meta_oracle_connection

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

        # one logical connection per thread - reused across all fetches in that thread
        Thread.current[THREAD_KEY] ||= ::OCI8.new(@username, @password, @pool)
      end

      def release_thread_connection
        connection = Thread.current[THREAD_KEY]
        return unless connection
        connection.logoff
      rescue
        # connection may already be closed
      ensure
        Thread.current[THREAD_KEY] = nil
      end

      def disconnect
        release_thread_connection
        return unless @pool
        @pool.destroy
        Log.info("Logged off from #{@username}@#{@database_instance}")
        @pool = nil
      end
    end
  end
end
