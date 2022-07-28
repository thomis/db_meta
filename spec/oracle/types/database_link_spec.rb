require "spec_helper"

RSpec.describe DbMeta::Oracle::DatabaseLink do
  let!(:synonym) {
    DbMeta::Oracle::DatabaseLink.new("OBJECT_TYPE" => "DATABASE LINK", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(synonym.ddl_drop).to eq("DROP DATABASE LINK EXAMPLE;")
  end

  it "is not a system object" do
    expect(synonym.system_object?).to eq(false)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["username", "password", "host"]])
    }
    synonym.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      CREATE DATABASE LINK EXAMPLE
       CONNECT TO username
       IDENTIFIED BY :1
       USING 'host';
    EOS
    expect(synonym.extract).to eq(stmt)
  end
end
