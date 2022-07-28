require "spec_helper"

RSpec.describe DbMeta::Oracle::Lob do
  let!(:lob) {
    DbMeta::Oracle::Lob.new("OBJECT_TYPE" => "LOB", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(lob.ddl_drop).to eq("DROP LOB EXAMPLE;")
  end

  it "is not a system object" do
    expect(lob.system_object?).to eq(false)
  end

  it "is embedded type" do
    expect(lob.extract_type).to eq(:embedded)
  end
end
