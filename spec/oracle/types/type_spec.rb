require "spec_helper"

RSpec.describe DbMeta::Oracle::Type do
  let!(:type) {
    described_class.new("OBJECT_TYPE" => "TYPE", "OBJECT_NAME" => "EXAMPLE_T")
  }

  before do
    allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
  end

  it "has drop statement" do
    expect(type.ddl_drop).to eq("DROP TYPE EXAMPLE_T;")
  end

  it "is not a system object" do
    expect(type.system_object?).to eq(false)
  end

  it "fetches type source and body and extracts both" do
    fake = FakeConnection.instance
    type_cursor = FakeCursor.new(rows: [["TYPE EXAMPLE_T AS OBJECT(ID NUMBER);\n"]])
    body_cursor = FakeCursor.new(rows: [["TYPE BODY EXAMPLE_T IS END;\n"]])
    allow(fake).to receive(:exec).and_return(type_cursor, body_cursor)

    type.fetch
    output = type.extract
    expect(output).to include("CREATE OR REPLACE TYPE EXAMPLE_T")
    expect(output).to include("CREATE OR REPLACE TYPE BODY EXAMPLE_T")
  end

  it "skips body section when none exists" do
    fake = FakeConnection.instance
    type_cursor = FakeCursor.new(rows: [["TYPE EXAMPLE_T AS OBJECT(ID NUMBER);\n"]])
    body_cursor = FakeCursor.new(rows: [])
    allow(fake).to receive(:exec).and_return(type_cursor, body_cursor)

    type.fetch
    output = type.extract
    expect(output).to include("CREATE OR REPLACE TYPE EXAMPLE_T")
    expect(output).not_to include("CREATE OR REPLACE TYPE BODY")
  end
end
