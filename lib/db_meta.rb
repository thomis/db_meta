require_relative 'db_meta/version'
require_relative 'db_meta/abstract'

module DbMeta

  DATABASE_TYPES = [:oracle]

  class DbMeta

    def initialize(**args)
      @args = args

      @username = args[:username]
      @password = args[:password]
      @instance = args[:instance]

      @database_type = args[:database_type] || DATABASE_TYPES[0]
    end

    def fetch
      validate
    end

    def extract
      validate
    end

    private

    def validate
      raise 'username is mandatory, pass a username argument during initialization' if @username.nil?
      raise 'password is mandatory, pass a password argument during initialization' if @password.nil?
      raise 'instance is mandatory, pass a instance argument during initialization' if @instance.nil?
      raise "allowed database types are [#{DATABASE_TYPES.join(', ')}], but provided was [#{@database_type}]" unless DATABASE_TYPES.include?(@database_type)
    end

  end

end
