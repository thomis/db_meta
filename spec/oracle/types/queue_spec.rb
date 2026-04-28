require "spec_helper"

RSpec.describe DbMeta::Oracle::Queue do
  let!(:queue) {
    described_class.new("OBJECT_TYPE" => "QUEUE", "OBJECT_NAME" => "EXAMPLE_Q")
  }

  before do
    allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
  end

  it "has drop statement" do
    expect(queue.ddl_drop).to include("dbms_aqadm.drop_queue")
  end

  it "is not a system object" do
    expect(queue.system_object?).to eq(false)
  end

  it "fetches and extracts a queue with translated sort order" do
    fake = FakeConnection.instance
    cursor_q = FakeCursor.new(hash_rows: [
      {"QUEUE_TABLE" => "EXAMPLE_QT", "QUEUE_TYPE" => "NORMAL_QUEUE", "MAX_RETRIES" => 5, "RETRY_DELAY" => 30}
    ])
    cursor_qt = FakeCursor.new(hash_rows: [
      {"OBJECT_TYPE" => "MY_PAYLOAD", "SORT_ORDER" => "ENQUEUE_TIME", "COMPATIBLE" => "10.0.0"}
    ])
    allow(fake).to receive(:exec).and_return(cursor_q, cursor_qt)

    queue.fetch
    expect(queue.queue_table).to eq("EXAMPLE_QT")
    expect(queue.payload_type).to eq("MY_PAYLOAD")

    output = queue.extract
    expect(output).to include("dbms_aqadm.create_queue_table")
    expect(output).to include("dbms_aqadm.create_queue")
    expect(output).to include("ENQ_TIME")
    expect(output).not_to include("ENQUEUE_TIME")
  end
end
