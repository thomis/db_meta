module DbMeta
  module Oracle
    class Synonym < Base
      register_type("SYNONYM")

      attr_reader :table_owner, :table_name, :db_link

      def initialize(args = {})
        super(args)

        @extract_type = :merged
      end

      def fetch(args = {})
        connection_class = args[:connection_class] || Connection
        connection = connection_class.instance.get
        cursor = connection.exec("select table_owner, table_name, db_link from user_synonyms where synonym_name = '#{@name}'")
        while (row = cursor.fetch)
          @table_owner = row[0].to_s
          @table_name = row[1].to_s
          @db_link = row[2].to_s
        end
        cursor.close
      ensure
        connection.logoff
      end

      def extract(args = {})
        line = ""
        line << "CREATE OR REPLACE SYNONYM #{@name} FOR "
        line << "#{@table_owner}." if @table_owner.size > 0
        line << @table_name.to_s
        line << "@#{@db_link}" if @db_link.size > 0
        line << ";"

        buffer = []
        buffer << line
        buffer.join("\n")
      end
    end
  end
end
