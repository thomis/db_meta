require "spec_helper"

RSpec.describe DbMeta::Oracle::Index do
  let!(:index) {
    DbMeta::Oracle::Index.new("OBJECT_TYPE" => "INDEX", "OBJECT_NAME" => "EXAMPLE")
  }

  let!(:index2) {
    DbMeta::Oracle::Index.new("OBJECT_TYPE" => "INDEX", "OBJECT_NAME" => "$EXAMPLE")
  }

  it "has drop statement" do
    expect(index.ddl_drop).to eq("DROP INDEX EXAMPLE;")
  end

  it "is not a system object" do
    expect(index.system_object?).to eq(false)
  end

  it "is a system object" do
    expect(index2.system_object?).to eq(true)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    index_cursor = FakeCursor.new(rows: [["NORMAL", "EXAMPLE_T", "UNIQUE", "TS"]])
    columns_cursor = FakeCursor.new(rows: [["ID"], ["NAME"]])
    expr_cursor = FakeCursor.new(rows: [])
    allow(instance).to receive(:exec).and_return(index_cursor, columns_cursor, expr_cursor)

    index.fetch(connection_class: FakeConnection)
    expect(index.table_name).to eq("EXAMPLE_T")
    expect(index.uniqueness).to eq("UNIQUE")
    expect(index.extract).to eq("CREATE UNIQUE INDEX EXAMPLE ON EXAMPLE_T(ID, NAME);")
  end

  it "replaces sys_ columns with function expressions" do
    instance = FakeConnection.instance.get
    index_cursor = FakeCursor.new(rows: [["FUNCTION-BASED NORMAL", "T", "NONUNIQUE", "TS"]])
    columns_cursor = FakeCursor.new(rows: [["SYS_NC00001$"]])
    expr_cursor = FakeCursor.new(rows: [["UPPER(NAME)", 1]])
    allow(instance).to receive(:exec).and_return(index_cursor, columns_cursor, expr_cursor)

    index.fetch(connection_class: FakeConnection)
    expect(index.extract).to eq("CREATE INDEX EXAMPLE ON T(UPPER(NAME));")
  end
end
