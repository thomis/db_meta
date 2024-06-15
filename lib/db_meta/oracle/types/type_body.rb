module DbMeta
  module Oracle
    class TypeBody < Base
      register_type("TYPE BODY")

      def initialize(args = {})
        super
        @extract_type = :embedded
      end
    end
  end
end
