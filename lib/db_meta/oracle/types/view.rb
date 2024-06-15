module DbMeta
  module Oracle
    class View < Base
      register_type("VIEW")

      def initialize(args = {})
        super

        @comment = nil # view level comment
      end

      def fetch(args = {})
        @comment = Comment.find(type: "TABLE", name: @name)
        @columns = Column.all(object_name: @name)

        @source = ""
        connection = Connection.instance.get
        cursor = Connection.instance.get.exec("select text from user_views where view_name = '#{@name}'")
        while (row = cursor.fetch)
          @source << row[0].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        buffer = [block(@name)]
        buffer << "CREATE OR REPLACE VIEW #{@name}"
        buffer << "("

        # add columns
        @columns.each_with_index do |c, index|
          buffer << "  #{c.name}#{"," if index + 1 < @columns.size}"
        end

        buffer << ")"
        buffer << "AS"
        buffer << @source.strip
        buffer[-1] += ";"
        buffer << nil

        # view comments
        if @comment
          buffer << "COMMENT ON VIEW #{@name} IS '#{@comment.text("'", "''")}';"
        end

        # view column comments
        @columns.each do |column|
          next if column.comment.size == 0
          buffer << "COMMENT ON COLUMN #{@name}.#{column.name} IS '#{column.comment.gsub("'", "''")}';"
        end

        buffer.join("\n")
      end
    end
  end
end
