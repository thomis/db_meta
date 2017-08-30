module DbMeta
  module Oracle
    class Job < Base
      register_type('JOB')

      def initialize(args={})
        super(args)
        @extract_type = :embedded
      end

      def system_object?
        true
      end

    end
  end
end
