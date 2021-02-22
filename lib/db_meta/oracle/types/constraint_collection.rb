module DbMeta
  module Oracle
    class ConstraintCollection
      include DbMeta::Oracle::Helper

      attr_reader :name, :type, :status, :extract_type, :collection

      def initialize(args = {})
        @name = args[:name]
        @type = args[:type]
        @status = :valid
        @extract_type = :default
        @collection = []
      end

      def empty?
        @collection.size == 0
      end

      def <<(object)
        @collection << object
      end

      def extract(args = {})
        buffer = [block(@name)]
        title = nil
        @collection.sort_by { |o| [o.table_name, o.name] }.each do |object|
          buffer << block(object.table_name, 40) if title != object.table_name
          buffer << object.extract(args)
          title = object.table_name
        end
        buffer.join("\n")
      end

      def ddl_drop
        "-- will automatically be dropped with table object"
      end

      def system_object?
        false
      end
    end
  end
end
