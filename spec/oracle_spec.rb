require "spec_helper"

describe DbMeta::Oracle do
  it "has a table type" do
    object = DbMeta::Oracle::Base.from_type("OBJECT_TYPE" => "TABLE")
    expect(object.class).to eq(DbMeta::Oracle::Table)
  end

  it "fails with unknown oracle type" do
    object = DbMeta::Oracle::Base.from_type("OBJECT_TYPE" => "UNKNOWN")
    expect(object.class).to eq(DbMeta::Oracle::Base)
  end
end
