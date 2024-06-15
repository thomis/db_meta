module DbMeta
  module Oracle
    class PackageBody < Base
      register_type("PACKAGE BODY")

      def initialize(args = {})
        super
        @extract_type = :embedded
      end
    end
  end
end
