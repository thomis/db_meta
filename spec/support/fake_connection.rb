class FakeConnection
  include Singleton
  def get
    self
  end

  def exec(something)
  end

  def logoff
  end
end
