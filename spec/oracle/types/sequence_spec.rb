require "spec_helper"

RSpec.describe DbMeta::Oracle::Sequence do
  let!(:sequence) {
    DbMeta::Oracle::Sequence.new("OBJECT_TYPE" => "SEQUENCE", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(sequence.ddl_drop).to eq("DROP SEQUENCE EXAMPLE;")
  end

  it "is not a system object" do
    expect(sequence.system_object?).to eq(false)
  end

  it "fetches and extracts using min_value as start (comparable across schemas)" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [[1, 1000, 1, "N", "N", 5, 42]])
    }
    sequence.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      -- -----------------------------------------------------------------------------
      -- EXAMPLE
      -- -----------------------------------------------------------------------------
      CREATE SEQUENCE EXAMPLE
        START WITH 1
        INCREMENT BY 1
        MAXVALUE 1000
        MINVALUE 1
        NOCYCLE
        CACHE 5
        NOORDER
      ;
    EOS
    expect(sequence.extract).to eq(stmt)
  end

  it "uses last_number as start when preserve_sequence_position is set" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [[1, 1000, 2, "N", "N", 5, 4711]])
    }
    sequence.fetch(connection_class: FakeConnection)

    output = sequence.extract(preserve_sequence_position: true)
    expect(output).to include("START WITH 4711")
    expect(output).to include("INCREMENT BY 2")
  end
end
