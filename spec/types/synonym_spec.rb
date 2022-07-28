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
end
