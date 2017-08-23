require_relative 'db_meta/version'
require_relative 'db_meta/constant'
require_relative 'db_meta/logger'

require_relative 'db_meta/abstract'
require_relative 'db_meta/oracle/oracle'

Log = Logger.new(STDOUT)

module DbMeta

  DATABASE_TYPES = [:oracle]

  class DbMeta

    def initialize(args={})
      @database_type = args[:database_type] || DATABASE_TYPES[0]
      raise "allowed database types are [#{DATABASE_TYPES.join(', ')}], but provided was [#{@database_type}]" unless DATABASE_TYPES.include?(@database_type)
      @abstract = Abstract.from_type(@database_type, args)
    end

    def fetch(args={})
      Log.info("Fetching...")
      @abstract.fetch(args)
      Log.info("Fetch completed")
    # rescue => e
    #   Log.error(e.to_s)
    end

    def extract(args={})
      Log.info("Extracting...")
      @abstract.extract(args)
      Log.info("Extraction completed")
    # rescue => e
    #   Log.error(e.to_s)
    end

  end

end
