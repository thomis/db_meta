module DbMeta
  module Oracle
    class Constraint < Base
      register_type('CONSTRAINT')

      def initialize(args={})
        super(args)
        @extract_type = :embedded
      end

    end
  end
end
