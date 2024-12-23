module DbMeta
  module Oracle
    class Column
      attr_accessor :name, :type, :data_length, :data_precision, :data_scale, :nullable, :data_default, :comment

      def extract
        buffer = ("%-30s" % @name).to_s
        buffer << " #{convert_type}"
        buffer << " DEFAULT #{@data_default.strip}" if @data_default.size > 0
        buffer
      end

      def self.all(args = {})
        columns = []
        connection = Connection.instance.get
        cursor = connection.exec("select column_name, data_type, data_length, data_precision, data_scale, nullable, data_default from user_tab_columns where table_name = '#{args[:object_name]}' order by column_id")
        while (row = cursor.fetch)
          column = Column.new
          column.name = row[0].to_s
          column.type = row[1].to_s
          column.data_length = row[2].to_i
          column.data_precision = row[3].to_i
          column.data_scale = row[4].to_i
          column.nullable = row[5].to_s
          column.data_default = row[6].to_s

          # column comments
          cursor2 = connection.exec("select comments from user_col_comments where table_name = '#{args[:object_name]}' and column_name = '#{column.name}'")
          while (row2 = cursor2.fetch)
            column.comment = row2[0].to_s
          end
          cursor2.close
          columns << column

        end
        cursor.close

        columns
      rescue
        connection.loggoff
      end

      private

      def convert_type
        case @type
        when "FLOAT"
          buffer = @type.to_s
          buffer << "(#{@data_precision})" unless @data_precision == 0
          buffer
        when "NUMBER"
          buffer = @type.to_s
          buffer << "(#{@data_precision}" unless @data_precision == 0
          buffer << ",#{@data_scale}" unless @data_scale == 0
          buffer << ")" if buffer.include?("(")
          buffer
        when /CHAR|RAW/
          "#{@type}(#{@data_length} BYTE)"
        else
          @type
        end
      end
    end
  end
end
