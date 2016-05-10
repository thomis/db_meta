require_relative 'db_meta/version'
require_relative 'db_meta/abstract'

require_relative 'db_meta/oracle/oracle'

module DbMeta

  DATABASE_TYPES = [:oracle]

  class DbMeta

    def initialize(**args)
      @database_type = args[:database_type] || DATABASE_TYPES[0]
      raise "allowed database types are [#{DATABASE_TYPES.join(', ')}], but provided was [#{@database_type}]" unless DATABASE_TYPES.include?(@database_type)
      @abstract = Abstract.from_type(@database_type, args)
    end

    def fetch(**args)
      abstract.fetch(args)
    end

    def extract(**args)
      abstract.extract(args)
    end

  end

end
