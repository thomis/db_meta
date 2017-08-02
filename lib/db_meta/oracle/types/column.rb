module DbMeta
  module Oracle
    class Column

      attr_accessor :name, :type, :data_length, :data_precision, :data_scale, :nullable, :data_default, :comment

      def initialize(args={})
      end

      def extract
        buffer = "#{'%-30s' % @name}"
        buffer << " #{ '%-25s' % convert_type}"
        buffer << '%-20s' % ( @data_default.size > 0 ? "DEFAULT #{@data_default}" : '' )
        buffer << '%-8s' % ( @nullable == 'Y' ? '' : 'NOT NULL')
        return buffer
      end

      def self.all(args={})
        columns = []
        cursor = Connection.instance.get.exec("select column_name, data_type, data_length, data_precision, data_scale, nullable, data_default from user_tab_columns where table_name = '#{args[:object_name]}' order by column_id")
        while row = cursor.fetch()
          column = Column.new(row)
          column.name = row[0].to_s
          column.type = row[1].to_s
          column.data_length = row[2].to_i
          column.data_precision = row[3].to_i
          column.data_scale = row[4].to_i
          column.nullable = row[5].to_s
          column.data_default = row[6].to_s

          # column comments
          cursor2 = Connection.instance.get.exec("select comments from user_col_comments where table_name = '#{args[:object_name]}' and column_name = '#{column.name}'")
          while row2 = cursor2.fetch()
            column.comment = row2[0].to_s
          end
          cursor2.close
          columns << column

        end
        cursor.close

        columns
      end

      private

      def convert_type
        case @type
          when 'FLOAT'
            buffer = "#{@type}"
            buffer << "(#{@data_precision})" unless @data_precision == 0
            return buffer
          when 'NUMBER'
            buffer = "#{@type}"
            buffer << "(#{@data_precision}" unless @data_precision == 0
            buffer << ",#{@data_scale}" unless @data_scale == 0
            buffer << ")" if buffer.include?("(")
            return buffer
          when /CHAR|RAW/
            return "#{@type}(#{@data_length} BYTE)"
        else
          return @type
        end
      end

    end
  end
end
