class FakeCursor
  def initialize(args = {})
    @rows = args[:rows] || []
    @hash_rows = args[:hash_rows] || []
    @index = 0
  end

  def fetch
    row = @rows[@index]
    @index += 1
    row
  end

  def fetch_hash
    @hash_rows.each { |row| yield row }
  end

  def close
  end
end
