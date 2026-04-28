require "spec_helper"

RSpec.describe DbMeta::Oracle::PackageBody do
  let!(:package_body) {
    DbMeta::Oracle::PackageBody.new("OBJECT_TYPE" => "PACKAGE BODY", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(package_body.ddl_drop).to eq("DROP PACKAGE BODY EXAMPLE;")
  end

  it "is not a system object" do
    expect(package_body.system_object?).to eq(false)
  end

  it "is embedded type" do
    expect(package_body.extract_type).to eq(:embedded)
  end
end
