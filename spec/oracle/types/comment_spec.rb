require "spec_helper"

RSpec.describe DbMeta::Oracle::Comment do
  before do
    allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
  end

  it "executes the lookup query" do
    fake = FakeConnection.instance
    expect(fake).to receive(:exec).with(
      "select comments from user_tab_comments where table_type = 'TABLE' and table_name = 'EXAMPLE'"
    ).and_return(FakeCursor.new(rows: [["a comment"]]))

    described_class.find(type: "TABLE", name: "EXAMPLE")
  end
end
