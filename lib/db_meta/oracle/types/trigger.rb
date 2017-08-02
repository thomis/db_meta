module DbMeta
  module Oracle
    class Trigger < Base
      register_type(:trigger)

      attr_accessor :trigger_type, :trigger_event, :for_each, :table_name, :referencing_names, :description, :tigger_body

      def initialize(args={})
        super(args)
      end

      def fetch
        cursor = Connection.instance.get.exec("select trigger_type, triggering_event, table_name, referencing_names, description, trigger_body from user_triggers where trigger_name = '#{@name}'")
        while row = cursor.fetch()
          @trigger_type = row[0].to_s
          @triggering_event = row[1].to_s
          @table_name = row[2].to_s
          @referencing_names = row[3].to_s
          @description = row[4].to_s
          @trigger_body = row[5].to_s
        end

        parse_trigger_type

        cursor.close
      end

      def extract(args={})
        buffer = []
        buffer << "CREATE OR REPLACE TRIGGER #{@name}"
        buffer << "#{@trigger_type} #{@triggering_event}"
        buffer << "ON #{@table_name}"
        buffer << "#{@referencing_names}"
        buffer << "#{@for_each}" if @for_each
        buffer << "#{@trigger_body.strip}"
        buffer << '/'
        buffer << nil
        buffer.join("\n")
      end

      private

      def parse_trigger_type
        @for_each = 'FOR EACH ROW' if @trigger_type =~ /each row/i

        case @trigger_type
          when /before/i
            @trigger_type = 'BEFORE'
          when /after/i
            @trigger_type = 'AFTER'
          when /instead of/i
            @for_each = 'FOR EACH ROW'
        end

      end

    end
  end
end