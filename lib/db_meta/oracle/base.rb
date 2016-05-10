module DbMeta
  module Oracle
    class Base

      TYPES = {}

      def self.register_type(type)
        TYPES[type] = self
      end

      def self.from_type(type, **args)
        raise "Oracle type [#{type}] is unknown" unless TYPES.keys.include?(type)
        TYPES[type].new(args)
      end

      def initialize(**args)
      end

    end
  end
end
