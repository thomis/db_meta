require "spec_helper"

RSpec.describe DbMeta::Oracle::SynonymCollection do
  let(:collection) { described_class.new(name: "ALL", type: "SYNONYM") }

  let(:synonym) do
    s = DbMeta::Oracle::Synonym.new("OBJECT_TYPE" => "SYNONYM", "OBJECT_NAME" => "S1")
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["OWNER", "TABLE", ""]])
    }
    s.fetch(connection_class: FakeConnection)
    s
  end

  it "is empty by default" do
    expect(collection.empty?).to eq(true)
  end

  it "is not a system object" do
    expect(collection.system_object?).to eq(false)
  end

  it "appends and exposes the collection" do
    collection << synonym
    expect(collection.empty?).to eq(false)
    expect(collection.collection).to eq([synonym])
  end

  it "extracts a block with each synonym" do
    collection << synonym
    output = collection.extract
    expect(output).to include("ALL")
    expect(output).to include("CREATE OR REPLACE SYNONYM S1")
  end

  it "produces drop statements in reverse order" do
    collection << synonym
    expect(collection.ddl_drop).to eq("DROP SYNONYM S1;")
  end
end
