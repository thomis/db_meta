module DbMeta
  module Oracle
    class MaterializedView < Base
      register_type('MATERIALIZED VIEW')

      attr_reader :query, :build_mode, :refresh_mode, :refresh_method, :interval, :next_date, :rewrite_enabled, :columns

      def fetch(args={})
        connection = Connection.instance.get

        cursor = connection.exec("select * from user_mviews where mview_name = '#{@name}'")
        cursor.fetch_hash do |item|
          @query = item['QUERY']
          @build_mode = item['BUILD_MODE']
          @refresh_mode = item['REFRESH_MODE']
          @refresh_method = item['REFRESH_METHOD']
          @rewrite_enabled = item['REWRITE_ENABLED'] == 'Y' ? 'ENABLE' : 'DISABLE'
        end
        cursor.close

        cursor = connection.exec("select * from user_refresh where rname = '#{@name}'")
        cursor.fetch_hash do |item|
          @interval = item['INTERVAL']
          @next_date = item['NEXT_DATE']
        end
        cursor.close

        @columns = Column.all(object_name: @name)

        # comments on materialized views
        cursor = connection.exec("select * from user_mview_comments where mview_name = '#{@name}'")
        cursor.fetch_hash do |item|
          @comment = item['COMMENTS']
        end
        cursor.close

      ensure
        connection.logoff
      end


      def extract(args={})
        buffer = [block(@name)]
        buffer << "CREATE MATERIALIZED VIEW #{@name}(#{@columns.map{ |c| c.name}.join(', ')})"
        buffer << "BUILD #{@build_mode}"
        buffer << "REFRESH #{@refresh_method} ON #{@refresh_mode}"
        buffer << "START WITH TO_DATE('#{@next_date}') NEXT #{@interval}" if @interval
        buffer << "#{@rewrite_enabled} QUERY REWRITE"
        buffer << 'AS'
        buffer << @query
        buffer << '/'
        buffer << nil

        # materialized view comments
        if @comment
          buffer << "COMMENT ON MATERIALIZED VIEW #{@name} IS '#{@comment.gsub("'","''")}';"
          buffer << nil
        end

        buffer.join("\n")
      end

    end
  end
end
