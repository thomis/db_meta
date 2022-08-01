require "spec_helper"

RSpec.describe DbMeta::Oracle::Function do
  let!(:function) {
    DbMeta::Oracle::Function.new("OBJECT_TYPE" => "FUNCTION", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(function.ddl_drop).to eq("DROP FUNCTION EXAMPLE;")
  end

  it "is not a system object" do
    expect(function.system_object?).to eq(false)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["CODE"]])
    }
    function.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      -- -----------------------------------------------------------------------------
      -- EXAMPLE
      -- -----------------------------------------------------------------------------
      create or replace CODE
      /
    EOS
    expect(function.extract).to eq(stmt)
  end
end
