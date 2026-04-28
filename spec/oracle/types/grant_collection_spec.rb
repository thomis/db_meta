require "spec_helper"

RSpec.describe DbMeta::Oracle::GrantCollection do
  let(:collection) { described_class.new(name: "ALL", type: "GRANT") }

  let(:grant) do
    g = DbMeta::Oracle::Grant.new(
      "OBJECT_TYPE" => "GRANT",
      "OBJECT_NAME" => "GRANTEE,OWNER,TBL,OWNER,SELECT,NO"
    )
    allow(FakeConnection.instance).to receive(:username).and_return("OWNER")
    g.fetch(connection_class: FakeConnection)
    g
  end

  it "is empty by default" do
    expect(collection.empty?).to eq(true)
  end

  it "is not a system object" do
    expect(collection.system_object?).to eq(false)
  end

  it "appends and exposes the collection" do
    collection << grant
    expect(collection.empty?).to eq(false)
    expect(collection.collection).to eq([grant])
  end

  it "extracts a block with each grant" do
    collection << grant
    output = collection.extract
    expect(output).to include("ALL")
    expect(output).to include("GRANT")
    expect(output).to include("GRANTEE")
  end

  it "produces drop statements" do
    collection << grant
    expect(collection.ddl_drop).to include("REVOKE")
  end
end
