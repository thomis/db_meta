module DbMeta
  module Oracle
    class Queue < Base
      register_type('QUEUE')

      attr_reader :queue_table, :queue_type, :max_retries, :retry_delay, :payload_type, :sort_order, :compatible

      def fetch
        connection = Connection.instance.get
        cursor = connection.exec("select * from user_queues where name = '#{@name}'")
        cursor.fetch_hash do |row|
          @queue_table = row['QUEUE_TABLE']
          @queue_type = row['QUEUE_TYPE']
          @max_retries = row['MAX_RETRIES'].to_i
          @retry_delay = row['RETRY_DELAY'].to_f
        end
        cursor.close

        cursor = connection.exec("select * from user_queue_tables where queue_table = '#{@queue_table}'")
        cursor.fetch_hash do |row|
          @payload_type = row['OBJECT_TYPE']
          @sort_order = row['SORT_ORDER']
          @compatible = row['COMPATIBLE']
        end
        cursor.close

      ensure
       connection.logoff
      end

      def extract(args={})
        buffer = [block(@name)]

        buffer << 'begin'
        buffer << '  dbms_aqadm.create_queue_table('
        buffer << "    queue_table => '#{@queue_table}',"
        buffer << "    queue_payload_type => '#{@payload_type}',"
        buffer << "    sort_list => '#{sort_order_translated}',"
        buffer << "    compatible => '#{@compatible}'"
        buffer << '  );'
        buffer << 'end;'
        buffer << '/'
        buffer << nil

        buffer << 'begin'
        buffer << '  dbms_aqadm.create_queue('
        buffer << "    queue_name => '#{@name}',"
        buffer << "    queue_table => '#{@queue_table}',"
        buffer << "    max_retires => #{@max_retries},"
        buffer << "    retry_delay => #{@retry_delay}"
        buffer << '  );'
        buffer << "  dbms_aqadm.start_queue('#{@name}');"
        buffer << "  dbms_aqadm.start_queue('AQ$_#{@queue_table}_E', false, true);"
        buffer << 'end;'
        buffer << '/'
        buffer << nil
        buffer.join("\n")
      end

      def ddl_drop
        buffer = []
        buffer << 'begin'
        buffer << "  dbms_aqadm.stop_queue('#{@name}');"
        buffer << "  dbms_aqadm.stop_queue('AQ$_#{@queue_table}_E');"
        buffer << "  dbms_aqadm.drop_queue(queue_name => '#{@name}');"
        buffer << "  dbms_aqadm.drop_queue_table(queue_table => '#{@queue_table}');"
        buffer << 'end;'
        buffer << '/'
        buffer.join("\n")
      end

      private

      def sort_order_translated
        # ENQUEUE_TIME => ENQ_TIME, seems to be inconsistent from Oracle
        @sort_order.gsub('ENQUEUE_TIME','ENQ_TIME')
      end

    end
  end
end
