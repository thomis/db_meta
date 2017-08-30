module DbMeta
  module Oracle
    class Job < Base
      register_type('JOB')

      def initialize(args={})
        super(args)
        @extract_type = :embedded
      end

    end
  end
end
