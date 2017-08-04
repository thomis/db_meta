module DbMeta

  class Abstract

    TYPES = {}

    def self.register_type(type)
      TYPES[type] = self
    end

    def self.from_type(type, args={})
      raise "Abstract type [#{type}] is unknown" unless TYPES.keys.include?(type)
      TYPES[type].new(args)
    end

    def initialize(args={})
      @username = args[:username]
      @password = args[:password]
      @instance = args[:instance]
      @worker = args[:worker] || 10

      @objects = []
      @invalid_objects = Hash.new([])

      @base_folder = args[:base_folder] || File.expand_path(File.join(Dir.pwd,"/#{@username}@#{@instance}"))

      raise 'username is mandatory, pass a username argument during initialization' if @username.nil?
      raise 'password is mandatory, pass a password argument during initialization' if @password.nil?
      raise 'instance is mandatory, pass a instance argument during initialization' if @instance.nil?
    end

    def fetch(args={})
      raise 'Needs to be implemented in derived class'
    end

    def extract(args={})
      raise 'Needs to be implemented in derived class'
    end

  end

end






