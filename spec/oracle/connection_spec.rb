require "spec_helper"

RSpec.describe DbMeta::Oracle::Connection do
  let(:connection) { described_class.instance }

  before do
    Thread.current[DbMeta::Oracle::Connection::THREAD_KEY] = nil
  end

  after do
    Thread.current[DbMeta::Oracle::Connection::THREAD_KEY] = nil
  end

  it "returns the same logical connection on repeated get within a thread" do
    fake = double("oci_connection")
    allow(connection).to receive(:get).and_wrap_original do |original|
      Thread.current[DbMeta::Oracle::Connection::THREAD_KEY] ||= fake
    end

    first = connection.get
    second = connection.get
    expect(first).to be(second)
  end

  it "release_thread_connection clears the cached connection" do
    fake = double("oci_connection", logoff: nil)
    Thread.current[DbMeta::Oracle::Connection::THREAD_KEY] = fake

    connection.release_thread_connection

    expect(fake).to have_received(:logoff)
    expect(Thread.current[DbMeta::Oracle::Connection::THREAD_KEY]).to be_nil
  end

  it "release_thread_connection swallows logoff errors" do
    fake = double("oci_connection")
    allow(fake).to receive(:logoff).and_raise(StandardError, "already closed")
    Thread.current[DbMeta::Oracle::Connection::THREAD_KEY] = fake

    expect { connection.release_thread_connection }.not_to raise_error
    expect(Thread.current[DbMeta::Oracle::Connection::THREAD_KEY]).to be_nil
  end
end
