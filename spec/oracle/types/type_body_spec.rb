require "spec_helper"

RSpec.describe DbMeta::Oracle::TypeBody do
  let!(:type_body) {
    DbMeta::Oracle::TypeBody.new("OBJECT_TYPE" => "TYPE BODY", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(type_body.ddl_drop).to eq("DROP TYPE BODY EXAMPLE;")
  end

  it "is not a system object" do
    expect(type_body.system_object?).to eq(false)
  end

  it "is embedded type" do
    expect(type_body.extract_type).to eq(:embedded)
  end
end
