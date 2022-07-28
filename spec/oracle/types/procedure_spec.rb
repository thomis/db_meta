require "spec_helper"

RSpec.describe DbMeta::Oracle::Procedure do
  let!(:procedure) {
    DbMeta::Oracle::Procedure.new("OBJECT_TYPE" => "PROCEDURE", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(procedure.ddl_drop).to eq("DROP PROCEDURE EXAMPLE;")
  end

  it "is not a system object" do
    expect(procedure.system_object?).to eq(false)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["CODE"]])
    }
    procedure.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      -- -----------------------------------------------------------------------------
      -- EXAMPLE
      -- -----------------------------------------------------------------------------
      create or replace CODE
      /
    EOS
    expect(procedure.extract).to eq(stmt)
  end
end
