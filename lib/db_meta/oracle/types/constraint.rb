module DbMeta
  module Oracle
    class Constraint < Base
      register_type('CONSTRAINT')

      attr_reader :constraint_type, :table_name, :search_condition, :referential_constraint, :delete_rule, :columns

      def initialize(args={})
        super(args)

        @extract_type = :embedded
        @columns = []
      end

      def fetch(args={})
        connection = Connection.instance.get
        cursor = connection.exec("select * from user_constraints where constraint_name = '#{@name}'")
        cursor.fetch_hash do |item|
          @constraint_type = translate_constraint_type(item['CONSTRAINT_TYPE'])
          @extract_type = :merged if @constraint_type == 'FOREIGN KEY'
          @table_name = item['TABLE_NAME']
          @search_condition = item['SEARCH_CONDITION']
          @delete_rule = item['DELETE_RULE']

          if @constraint_type == 'FOREIGN KEY'
            constraint = Constraint.new('OBJECT_TYPE' => 'CONSTRAINT', 'OBJECT_NAME' => item['R_CONSTRAINT_NAME'])
            constraint.fetch
            @referential_constraint = constraint
          end
        end
        cursor.close

        # get affected columns
        cursor = connection.exec("select * from user_cons_columns where constraint_name = '#{@name}' order by position")
        cursor.fetch_hash do |item|
          @columns << item['COLUMN_NAME']
        end
        cursor.close

      ensure
        connection.logoff
      end


      def extract(args={})
        buffer = []
        buffer << "ALTER TABLE #{@table_name} ADD ("
        buffer << "  CONSTRAINT #{@name}"

        case @constraint_type
          when 'CHECK'
            buffer << "  #{@constraint_type} (#{@search_condition})"
          when 'FOREIGN KEY'
            buffer << "  #{@constraint_type} (#{@columns.join(', ')})"
            buffer << "  REFERENCES #{@referential_constraint.table_name} (#{@referential_constraint.columns.join(', ')})"
          else
            buffer << "  #{@constraint_type} (#{@columns.join(', ')})"
        end

        buffer << "  ON DELETE CASCADE" if @delete_rule == 'CASCADE'
        buffer << "  ENABLE VALIDATE"
        buffer << ");"

        (0..buffer.size-1).each { |n|  buffer[n] = ('-- ' + buffer[n])}  if args[:comment] == true

        buffer << nil
        buffer.join("\n")
      end

      def self.sort_value(type)
        ['PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE', 'CHECK'].index(type)
      end

      private

      def translate_constraint_type(type)
        case type
          when 'P'
            return 'PRIMARY KEY'
          when 'U'
            return 'UNIQUE'
          when 'C'
            return 'CHECK'
          when 'R'
            return 'FOREIGN KEY'
        end
      end

    end
  end
end
