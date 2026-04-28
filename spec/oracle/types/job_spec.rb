require "spec_helper"

RSpec.describe DbMeta::Oracle::Job do
  let!(:job) {
    DbMeta::Oracle::Job.new("OBJECT_TYPE" => "JOB", "OBJECT_NAME" => "EXAMPLE")
  }

  it "has drop statement" do
    expect(job.ddl_drop).to eq("DROP JOB EXAMPLE;")
  end

  it "is a system object" do
    expect(job.system_object?).to eq(true)
  end

  it "is embedded type" do
    expect(job.extract_type).to eq(:embedded)
  end
end
