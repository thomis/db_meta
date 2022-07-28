require "spec_helper"

RSpec.describe DbMeta::Oracle::DatabaseLink do
  let!(:link) {
    DbMeta::Oracle::DatabaseLink.new("OBJECT_TYPE" => "DATABASE LINK", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(link.ddl_drop).to eq("DROP DATABASE LINK EXAMPLE;")
  end

  it "is not a system object" do
    expect(link.system_object?).to eq(false)
  end

  it "fetches and extracts" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["USERNAME", "PASSWORD", "HOST"]])
    }
    link.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      CREATE DATABASE LINK EXAMPLE
       CONNECT TO USERNAME
       IDENTIFIED BY :1
       USING 'HOST';
    EOS
    expect(link.extract).to eq(stmt)
  end
end
