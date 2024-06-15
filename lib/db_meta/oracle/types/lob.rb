module DbMeta
  module Oracle
    class Lob < Base
      register_type("LOB")

      def initialize(args = {})
        super
        @extract_type = :embedded
      end
    end
  end
end
