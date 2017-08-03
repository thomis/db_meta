module DbMeta
  module Oracle
    class Table < Base
      register_type('TABLE')

      def initialize(args={})
        super(args)

        @comment = nil # table level comment
      end


      def fetch
        fetch_comments
        @columns = Column.all(object_name: @name)
      end


      def extract(args={})
        buffer = []
        buffer << "CREATE TABLE #{@name}"
        buffer << '('

        # add columns
        @columns.each_with_index do |c, index|
          buffer << "  #{c.extract}#{',' if index+1 < @columns.size}"
        end

        buffer << ');'
        buffer << nil

        # table comments
        if @comment
          buffer << "COMMENT ON TABLE #{@name} IS '#{@comment.gsub("'","''")}';"
        end

        # table column comments
        @columns.each do |column|
          next if column.comment.size == 0
          buffer << "COMMENT ON COLUMN #{@name}.#{column.name} IS '#{column.comment.gsub("'","''")}';"
        end

        buffer.join("\n")
      end

      private

      def fetch_comments
        return unless @name
        cursor = Connection.instance.get.exec("select comments from user_tab_comments where table_type = 'TABLE' and table_name = '#{@name}'")
        while row = cursor.fetch()
          @comment = row[0]
        end
        cursor.close
      end

    end
  end
end
