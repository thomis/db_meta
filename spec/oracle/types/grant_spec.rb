require "spec_helper"

RSpec.describe DbMeta::Oracle::Grant do
  let!(:grant) {
    name = "GRANTEE,OWNER,TABLE,GRANTOR,PRIVILEGE,YES"
    DbMeta::Oracle::Grant.new("OBJECT_TYPE" => "GRANT", "OBJECT_NAME" => name)
  }

  let!(:grant2) {
    name = "GRANTEE,OWNER,TABLE,GRANTOR_OTHER,PRIVILEGE,YES"
    DbMeta::Oracle::Grant.new("OBJECT_TYPE" => "GRANT", "OBJECT_NAME" => name)
  }

  it "is not a system object" do
    expect(grant.system_object?).to eq(false)
  end

  it "has drop statement" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:username) { "GRANTOR" }
    grant.fetch(connection_class: FakeConnection)
    expect(grant.ddl_drop).to eq("REVOKE PRIVILEGE          ON TABLE                            FROM GRANTEE;")
  end

  it "fetches and ectracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:username) { "GRANTOR" }
    grant.fetch(connection_class: FakeConnection)
    expect(grant.extract).to eq("GRANT PRIVILEGE          ON TABLE                            TO GRANTEE WITH GRANT OPTION;")
  end

  it "returns sorted value" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:username) { "GRANTOR" }
    grant.fetch(connection_class: FakeConnection)
    expect(grant.sort_value).to eq(["1", "GRANTEE", "PRIVILEGE", "TABLE"])
  end

  context "foreign grants" do
    it "has drop statement" do
      instance = FakeConnection.instance.get
      allow(instance).to receive(:username) { "GRANTEE" }
      grant2.fetch(connection_class: FakeConnection)
      expect(grant2.ddl_drop).to eq("-- granted via GRANTOR_OTHER: REVOKE PRIVILEGE          ON TABLE                            FROM GRANTEE;")
    end

    it "fetches and ectracts" do
      instance = FakeConnection.instance.get
      allow(instance).to receive(:username) { "GRANTEE" }
      grant2.fetch(connection_class: FakeConnection)
      expect(grant2.extract).to eq("-- granted via GRANTOR_OTHER: GRANT PRIVILEGE          ON TABLE                            TO GRANTEE WITH GRANT OPTION;")
    end

    it "returns sorted value" do
      instance = FakeConnection.instance.get
      allow(instance).to receive(:username) { "GRANTOR" }
      grant2.fetch(connection_class: FakeConnection)
      expect(grant2.sort_value).to eq(["2", "GRANTOR_OTHER", "PRIVILEGE", "TABLE"])
    end
  end
end
