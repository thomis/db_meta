module DbMeta
  module Oracle
    class Index < Base
      register_type("INDEX")

      attr_reader :index_type, :table_name, :uniqueness, :tablespace

      def initialize(args = {})
        super(args)

        @extract_type = :embedded
        @columns = []
      end

      def fetch(args = {})
        connection = Connection.instance.get
        cursor = connection.exec("select index_type, table_name, uniqueness, tablespace_name from user_indexes where index_name = '#{@name}'")
        while (row = cursor.fetch)
          @index_type = row[0].to_s
          @table_name = row[1].to_s
          @uniqueness = row[2].to_s
          @tablespace = row[3].to_s
        end
        cursor.close

        # involved columns
        cursor = connection.exec("select column_name from user_ind_columns where index_name = '#{@name}' order by column_position")
        while (row = cursor.fetch)
          @columns << row[0].to_s
        end
        cursor.close

        # columns for function based indexs
        cursor = connection.exec("select column_expression, column_position from user_ind_expressions where index_name = '#{@name}' order by column_position")
        while (row = cursor.fetch)
          idx = row[1].to_i - 1
          @columns[idx] = row[0] # replace sys_... entry
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        "CREATE#{@uniqueness == "UNIQUE" ? " UNIQUE" : nil} INDEX #{@name} ON #{@table_name}(#{@columns.join(", ")});"
      end
    end
  end
end
