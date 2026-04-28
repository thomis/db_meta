require "spec_helper"

RSpec.describe DbMeta::Oracle::TableDataCollection do
  let(:tables) { [] }
  let(:collection) {
    described_class.new(name: "ALL DATA", type: "DATA", tables: tables)
  }

  it "ddl_drop is a comment about table cascade" do
    expect(collection.ddl_drop).to include("automatically be dropped")
  end

  it "is not a system object" do
    expect(collection.system_object?).to eq(false)
  end

  describe "#format_values" do
    let(:format) {
      ->(map, item) { collection.send(:format_values, map, item) }
    }

    it "renders NULL for nil values" do
      expect(format.call({"X" => "NUMBER"}, {"X" => nil})).to eq("NULL")
    end

    it "escapes single quotes for varchar values" do
      expect(format.call({"X" => "VARCHAR2"}, {"X" => "it's"})).to eq("'it''s'")
    end

    it "renders date values via to_date" do
      time = Time.new(2026, 1, 2, 3, 4, 5)
      output = format.call({"X" => "DATE"}, {"X" => time})
      expect(output).to start_with("to_date(")
      expect(output).to include("2026-01-02 03:04:05")
    end

    it "renders raw values quoted" do
      expect(format.call({"X" => "RAW"}, {"X" => "DEADBEEF"})).to eq("'DEADBEEF'")
    end

    it "renders unknown types as plain to_s" do
      expect(format.call({"X" => "NUMBER"}, {"X" => 42})).to eq("42")
    end
  end
end
