module DbMeta
  module Oracle
    class Base

      TYPES = {}

      attr_accessor :type, :status, :name

      def self.register_type(type)
        TYPES[type] = self
      end

      def self.from_type(args={})
        type = args['OBJECT_TYPE']

        # return instance of known type
        return TYPES[type].new(args) if TYPES.keys.include?(type)

        # There is no implementation for this type yet. Let's just use Base
        Log.warn("Don't know how to handle oracle type [#{type}] yet")
        Base.new(args)
      end

      def initialize(args={})
        @type = args['OBJECT_TYPE']
        @name = args['OBJECT_NAME']

        @status = :unknown
        @status = args['STATUS'].downcase.to_sym if args['STATUS']

        fetch
      end


      def fetch
      end

      def extract(args={})
        'needs to be implemented'
      end

    end
  end
end
