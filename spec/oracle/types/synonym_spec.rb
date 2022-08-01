require "spec_helper"

RSpec.describe DbMeta::Oracle::Synonym do
  let!(:synonym) {
    DbMeta::Oracle::Synonym.new("OBJECT_TYPE" => "SYNONYM", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(synonym.ddl_drop).to eq("DROP SYNONYM EXAMPLE;")
  end

  it "is not a system object" do
    expect(synonym.system_object?).to eq(false)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["OWNER", "TABLE", "LINK"]])
    }

    synonym.fetch(connection_class: FakeConnection)
    expect(synonym.extract).to eq("CREATE OR REPLACE SYNONYM EXAMPLE FOR OWNER.TABLE@LINK;")
  end
end
