require "spec_helper"

RSpec.describe DbMeta::Oracle::Trigger do
  let!(:trigger) {
    DbMeta::Oracle::Trigger.new("OBJECT_TYPE" => "TRIGGER", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(trigger.ddl_drop).to eq("DROP TRIGGER EXAMPLE;")
  end

  it "is not a system object" do
    expect(trigger.system_object?).to eq(false)
  end

  it "fetches and extracts before trigger" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["BEFORE", "EVENT", "TABLE", "REFERENCING NAMES", "DESCRIPTION", "BODY;"]])
    }
    trigger.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      CREATE OR REPLACE TRIGGER EXAMPLE
      BEFORE EVENT
      ON TABLE
      REFERENCING NAMES
      BODY;
      /
    EOS
    expect(trigger.extract).to eq(stmt)
  end

  it "fetches and extracts after trigger" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["AFTER", "EVENT", "TABLE", "REFERENCING NAMES", "DESCRIPTION", "BODY;"]])
    }
    trigger.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      CREATE OR REPLACE TRIGGER EXAMPLE
      AFTER EVENT
      ON TABLE
      REFERENCING NAMES
      BODY;
      /
    EOS
    expect(trigger.extract).to eq(stmt)
  end

  it "fetches and extracts instead of trigger" do
    instance = FakeConnection.instance.get
    allow(instance).to receive(:exec) {
      FakeCursor.new(rows: [["INSTEAD OF", "EVENT", "TABLE", "REFERENCING NAMES", "DESCRIPTION", "BODY;"]])
    }
    trigger.fetch(connection_class: FakeConnection)

    stmt = <<~EOS
      CREATE OR REPLACE TRIGGER EXAMPLE
      INSTEAD OF EVENT
      ON TABLE
      REFERENCING NAMES
      FOR EACH ROW
      BODY;
      /
    EOS
    expect(trigger.extract).to eq(stmt)
  end
end
