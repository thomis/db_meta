require "spec_helper"

RSpec.describe DbMeta::Oracle::Sequence do
  let!(:synonym) {
    DbMeta::Oracle::Sequence.new("OBJECT_TYPE" => "SEQUENCE", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(synonym.ddl_drop).to eq("DROP SEQUENCE EXAMPLE;")
  end

  it "is not a system object" do
    expect(synonym.system_object?).to eq(false)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [[1, 1000, 1, "N", "N", 5, 1]])
    }
    synonym.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      -- -----------------------------------------------------------------------------
      -- EXAMPLE
      -- -----------------------------------------------------------------------------
      CREATE SEQUENCE EXAMPLE
        START WITH 1
        MAXVALUE 1000
        MINVALUE 1
        NOCYCLE
        CACHE 5
        NOORDER
      ;
    EOS
    expect(synonym.extract).to eq(stmt)
  end
end
