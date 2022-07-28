require "spec_helper"

RSpec.describe DbMeta::Oracle::Index do
  let!(:index) {
    DbMeta::Oracle::Index.new("OBJECT_TYPE" => "INDEX", "OBJECT_NAME" => "EXAMPLE")
  }

  let!(:index2) {
    DbMeta::Oracle::Index.new("OBJECT_TYPE" => "INDEX", "OBJECT_NAME" => "$EXAMPLE")
  }

  it "has drop statement" do
    expect(index.ddl_drop).to eq("DROP INDEX EXAMPLE;")
  end

  it "is not a system object" do
    expect(index.system_object?).to eq(false)
  end

  it "is a system object" do
    expect(index2.system_object?).to eq(true)
  end
end
