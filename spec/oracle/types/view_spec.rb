require "spec_helper"

RSpec.describe DbMeta::Oracle::View do
  let!(:view) {
    described_class.new("OBJECT_TYPE" => "VIEW", "OBJECT_NAME" => "EXAMPLE_V")
  }

  before do
    allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
  end

  it "has drop statement" do
    expect(view.ddl_drop).to eq("DROP VIEW EXAMPLE_V;")
  end

  it "is not a system object" do
    expect(view.system_object?).to eq(false)
  end

  it "fetches and extracts a view source with columns" do
    fake = FakeConnection.instance
    table_comment_cursor = FakeCursor.new(rows: [])
    column_cursor = FakeCursor.new(rows: [["ID", "NUMBER", 10, 10, 0, "N", ""]])
    column_comment_cursor = FakeCursor.new(rows: [])
    source_cursor = FakeCursor.new(rows: [["select id from t"]])
    allow(fake).to receive(:exec).and_return(table_comment_cursor, column_cursor, column_comment_cursor, source_cursor)

    view.fetch

    output = view.extract
    expect(output).to include("CREATE OR REPLACE VIEW EXAMPLE_V")
    expect(output).to include("select id from t")
    expect(output).to include("ID")
  end
end
