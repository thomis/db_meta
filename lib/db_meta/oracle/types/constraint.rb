module DbMeta
  module Oracle
    class Constraint < Base
      register_type("CONSTRAINT")

      attr_reader :constraint_type, :table_name, :search_condition, :referential_constraint, :delete_rule, :columns

      @@cache = {}
      @@cache_mutex = Mutex.new

      def self.preload(args = {})
        connection_class = args[:connection_class] || Connection
        connection = connection_class.instance.get

        meta = {}
        cursor = connection.exec(
          "select constraint_name, constraint_type, table_name, search_condition, r_constraint_name, delete_rule " \
          "from user_constraints"
        )
        cursor.fetch_hash do |row|
          name = row["CONSTRAINT_NAME"]
          type = translate_constraint_type(row["CONSTRAINT_TYPE"])
          search_condition = row["SEARCH_CONDITION"]

          # Skip Oracle-generated NOT NULL CHECK constraints. They are already
          # represented by the column's NOT NULL clause in the table DDL, so
          # emitting them again is redundant noise that breaks schema diffs.
          next if redundant_not_null?(name, type, search_condition)

          meta[name] = {
            constraint_type: type,
            table_name: row["TABLE_NAME"],
            search_condition: search_condition,
            r_constraint_name: row["R_CONSTRAINT_NAME"],
            delete_rule: row["DELETE_RULE"],
            columns: []
          }
        end
        cursor.close

        cursor = connection.exec(
          "select constraint_name, column_name, position " \
          "from user_cons_columns order by constraint_name, position"
        )
        cursor.fetch_hash do |row|
          entry = meta[row["CONSTRAINT_NAME"]]
          next unless entry
          entry[:columns] << row["COLUMN_NAME"]
        end
        cursor.close

        @@cache_mutex.synchronize { @@cache = meta }
      end

      def self.system_generated?(name)
        name.to_s.start_with?("SYS_")
      end

      def self.redundant_not_null?(name, type, search_condition)
        return false unless system_generated?(name) && type == "CHECK"
        return false if search_condition.nil?
        # Match patterns like: "COL_NAME" IS NOT NULL  or  COL_NAME IS NOT NULL
        !!search_condition.match?(/\A\s*"?[A-Z0-9_$#]+"?\s+IS\s+NOT\s+NULL\s*\z/i)
      end

      def self.cache
        @@cache
      end

      def self.reset_cache
        @@cache_mutex.synchronize { @@cache = {} }
      end

      def initialize(args = {})
        super

        @extract_type = :embedded
        @columns = []
      end

      def fetch(args = {})
        entry = @@cache[@name]
        return unless entry

        @constraint_type = entry[:constraint_type]
        @table_name = entry[:table_name]
        @search_condition = entry[:search_condition]
        @delete_rule = entry[:delete_rule]
        @columns = entry[:columns].dup
        @extract_type = :merged if @constraint_type == "FOREIGN KEY"

        if @constraint_type == "FOREIGN KEY" && entry[:r_constraint_name]
          @referential_constraint = Constraint.new(
            "OBJECT_TYPE" => "CONSTRAINT",
            "OBJECT_NAME" => entry[:r_constraint_name]
          )
          @referential_constraint.fetch
        end
      end

      def extract(args = {})
        buffer = []
        buffer << "ALTER TABLE #{@table_name} ADD ("
        buffer << "  CONSTRAINT #{@name}" unless Constraint.system_generated?(@name)

        case @constraint_type
        when "CHECK"
          buffer << "  #{@constraint_type} (#{@search_condition})"
        when "FOREIGN KEY"
          buffer << "  #{@constraint_type} (#{@columns.join(", ")})"
          buffer << "  REFERENCES #{@referential_constraint.table_name} (#{@referential_constraint.columns.join(", ")})"
        else
          buffer << "  #{@constraint_type} (#{@columns.join(", ")})"
        end

        buffer << "  ON DELETE CASCADE" if @delete_rule == "CASCADE"
        buffer << "  ENABLE VALIDATE"
        buffer << ");"

        (0..buffer.size - 1).each { |n| buffer[n] = ("-- " + buffer[n]) } if args[:comment] == true

        buffer << nil
        buffer.join("\n")
      end

      def self.sort_value(type)
        ["PRIMARY KEY", "FOREIGN KEY", "UNIQUE", "CHECK"].index(type)
      end

      def self.translate_constraint_type(type)
        case type
        when "P"
          "PRIMARY KEY"
        when "U"
          "UNIQUE"
        when "C"
          "CHECK"
        when "R"
          "FOREIGN KEY"
        end
      end
    end
  end
end
