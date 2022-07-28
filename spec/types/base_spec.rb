require "spec_helper"

RSpec.describe DbMeta::Oracle::Base do
  let!(:base) {
    DbMeta::Oracle::Base.new("OBJECT_TYPE" => "SYNONYM", "OBJECT_NAME" => "EXAMPLE")
  }

  it "returns info when extracting" do
    expect(base.extract).to eq("-- class/method needs to be implemented")
  end
end
