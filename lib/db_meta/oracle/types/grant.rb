module DbMeta
  module Oracle
    class Grant < Base
      register_type('GRANT')

      def initialize(args={})
        super(args)
        @extract_type = :merged
      end

    end
  end
end
