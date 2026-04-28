require "spec_helper"

RSpec.describe DbMeta::Oracle::Package do
  let!(:package) {
    described_class.new("OBJECT_TYPE" => "PACKAGE", "OBJECT_NAME" => "EXAMPLE")
  }

  before do
    allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
  end

  it "has drop statement" do
    expect(package.ddl_drop).to eq("DROP PACKAGE EXAMPLE;")
  end

  it "is not a system object" do
    expect(package.system_object?).to eq(false)
  end

  it "fetches header and body and extracts" do
    fake = FakeConnection.instance
    header_cursor = FakeCursor.new(rows: [["PACKAGE EXAMPLE AS\n  PROCEDURE FOO; END;\n"]])
    body_cursor = FakeCursor.new(rows: [["PACKAGE BODY EXAMPLE AS\n  PROCEDURE FOO IS BEGIN NULL; END; END;\n"]])
    allow(fake).to receive(:exec).and_return(header_cursor, body_cursor)

    package.fetch
    expect(package.header).to include("PACKAGE EXAMPLE")
    expect(package.body).to include("PACKAGE BODY EXAMPLE")

    output = package.extract
    expect(output).to include("CREATE OR REPLACE PACKAGE EXAMPLE")
    expect(output).to include("CREATE OR REPLACE PACKAGE BODY EXAMPLE")
  end
end
