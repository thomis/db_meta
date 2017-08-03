module DbMeta
  module Oracle
    class View < Base
      register_type('VIEW')

      def fetch(args={})
        @columns = Column.all(object_name: @name)

        @source = ""
        cursor = Connection.instance.get.exec("select text from user_views where view_name = '#{@name}'")
        while row = cursor.fetch()
          @source << row[0].to_s
        end
        cursor.close

      end


      def extract(args={})
        buffer = []
        buffer << "CREATE OR REPLACE VIEW #{@name}"
        buffer << '('

        # add columns
        @columns.each_with_index do |c, index|
          buffer << "  #{c.name}#{',' if index+1 < @columns.size}"
        end

        buffer << ')'
        buffer << "AS"
        buffer << @source.strip
        buffer << ';'
        buffer << nil
        buffer.join("\n")
      end

    end
  end
end
