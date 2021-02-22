module DbMeta
  module Oracle
    class Lob < Base
      register_type("LOB")

      def initialize(args = {})
        super(args)
        @extract_type = :embedded
      end
    end
  end
end
