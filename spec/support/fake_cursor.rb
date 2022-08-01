class FakeCursor
  def initialize(args = {})
    @rows = args[:rows]
    @index = 0
  end

  def fetch
    row = @rows[@index]
    @index += 1
    row
  end

  def close
  end
end
