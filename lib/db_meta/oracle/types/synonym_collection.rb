module DbMeta
  module Oracle
    class SynonymCollection
      include DbMeta::Oracle::Helper

      attr_reader :name, :type, :status, :extract_type, :collection

      def initialize(args={})
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

      def extract(args={})
        buffer = [block(@name), nil]
        buffer << @collection.map{ |o| o.extract(args) }
        buffer << nil
        buffer.join("\n")
      end

      def ddl_drop
        @collection.map{ |o| o.ddl_drop }.join("\n")
      end

    end

  end
end
