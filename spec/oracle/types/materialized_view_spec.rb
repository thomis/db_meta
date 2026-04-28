require "spec_helper"

RSpec.describe DbMeta::Oracle::MaterializedView do
  let!(:mview) {
    described_class.new("OBJECT_TYPE" => "MATERIALIZED VIEW", "OBJECT_NAME" => "EXAMPLE_MV")
  }

  before do
    allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
  end

  it "has drop statement" do
    expect(mview.ddl_drop).to eq("DROP MATERIALIZED VIEW EXAMPLE_MV;")
  end

  it "is not a system object" do
    expect(mview.system_object?).to eq(false)
  end

  it "uses SYSDATE for the schedule start by default" do
    fake = FakeConnection.instance
    mview_cursor = FakeCursor.new(hash_rows: [
      {"QUERY" => "select 1 from dual", "BUILD_MODE" => "IMMEDIATE", "REFRESH_MODE" => "DEMAND",
       "REFRESH_METHOD" => "COMPLETE", "REWRITE_ENABLED" => "N"}
    ])
    refresh_cursor = FakeCursor.new(hash_rows: [{"INTERVAL" => "SYSDATE+1", "NEXT_DATE" => "2026-04-30"}])
    column_cursor = FakeCursor.new(rows: [])
    comment_cursor = FakeCursor.new(hash_rows: [])
    allow(fake).to receive(:exec).and_return(mview_cursor, refresh_cursor, column_cursor, comment_cursor)

    mview.fetch
    output = mview.extract
    expect(output).to include("START WITH SYSDATE NEXT SYSDATE+1")
    expect(output).not_to include("2026-04-30")
  end

  it "preserves the live next_date when preserve_mview_schedule is set" do
    fake = FakeConnection.instance
    mview_cursor = FakeCursor.new(hash_rows: [
      {"QUERY" => "select 1 from dual", "BUILD_MODE" => "IMMEDIATE", "REFRESH_MODE" => "DEMAND",
       "REFRESH_METHOD" => "COMPLETE", "REWRITE_ENABLED" => "N"}
    ])
    refresh_cursor = FakeCursor.new(hash_rows: [{"INTERVAL" => "SYSDATE+1", "NEXT_DATE" => "2026-04-30"}])
    column_cursor = FakeCursor.new(rows: [])
    comment_cursor = FakeCursor.new(hash_rows: [])
    allow(fake).to receive(:exec).and_return(mview_cursor, refresh_cursor, column_cursor, comment_cursor)

    mview.fetch
    output = mview.extract(preserve_mview_schedule: true)
    expect(output).to include("START WITH TO_DATE('2026-04-30') NEXT SYSDATE+1")
  end

  it "fetches and extracts" do
    fake = FakeConnection.instance
    mview_cursor = FakeCursor.new(hash_rows: [
      {
        "QUERY" => "select id from t",
        "BUILD_MODE" => "IMMEDIATE",
        "REFRESH_MODE" => "DEMAND",
        "REFRESH_METHOD" => "COMPLETE",
        "REWRITE_ENABLED" => "Y"
      }
    ])
    refresh_cursor = FakeCursor.new(hash_rows: [
      {"INTERVAL" => "SYSDATE+1", "NEXT_DATE" => "2026-01-01"}
    ])
    column_cursor = FakeCursor.new(rows: [["ID", "NUMBER", 10, 10, 0, "N", ""]])
    column_comment_cursor = FakeCursor.new(rows: [])
    comment_cursor = FakeCursor.new(hash_rows: [{"COMMENTS" => "a comment"}])

    allow(fake).to receive(:exec).and_return(
      mview_cursor, refresh_cursor, column_cursor, column_comment_cursor, comment_cursor
    )

    mview.fetch
    output = mview.extract
    expect(output).to include("CREATE MATERIALIZED VIEW EXAMPLE_MV")
    expect(output).to include("BUILD IMMEDIATE")
    expect(output).to include("REFRESH COMPLETE ON DEMAND")
    expect(output).to include("ENABLE QUERY REWRITE")
    expect(output).to include("a comment")
  end
end
