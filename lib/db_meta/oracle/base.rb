module DbMeta
  module Oracle
    class Base

      TYPES = {}

      attr_accessor :type, :status, :name

      def self.register_type(type)
        TYPES[type] = self
      end

      def self.from_type(type, args={})
        raise "Oracle type [#{type}] is unknown" unless TYPES.keys.include?(type)
        TYPES[type].new(args)
      end

      def initialize(args={})
        @type = args[:type]

        @name = args['OBJECT_NAME'].downcase if args['OBJECT_NAME']
        @status = :unknown
        @status = args['STATUS'].downcase.to_sym if args['STATUS']
      end

    end
  end
end
