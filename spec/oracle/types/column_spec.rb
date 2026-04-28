require "spec_helper"

RSpec.describe DbMeta::Oracle::Column do
  describe "#extract" do
    it "renders a NUMBER column with precision and scale" do
      column = described_class.new
      column.name = "AMOUNT"
      column.type = "NUMBER"
      column.data_length = 10
      column.data_precision = 10
      column.data_scale = 2
      column.nullable = "Y"
      column.data_default = ""
      expect(column.extract).to include("NUMBER(10,2)")
      expect(column.extract).to include("AMOUNT")
      expect(column.extract).not_to include("NOT NULL")
    end

    it "appends NOT NULL when the column is non-nullable" do
      column = described_class.new
      column.name = "ID"
      column.type = "NUMBER"
      column.data_length = 0
      column.data_precision = 10
      column.data_scale = 0
      column.nullable = "N"
      column.data_default = ""
      expect(column.extract).to include("NOT NULL")
    end

    it "renders a FLOAT with precision" do
      column = described_class.new
      column.name = "PCT"
      column.type = "FLOAT"
      column.data_length = 0
      column.data_precision = 5
      column.data_scale = 0
      column.nullable = "N"
      column.data_default = ""
      expect(column.extract).to include("FLOAT(5)")
    end

    it "renders a VARCHAR with byte length" do
      column = described_class.new
      column.name = "NAME"
      column.type = "VARCHAR2"
      column.data_length = 50
      column.data_precision = 0
      column.data_scale = 0
      column.nullable = "Y"
      column.data_default = ""
      expect(column.extract).to include("VARCHAR2(50 BYTE)")
    end

    it "includes a DEFAULT clause when present" do
      column = described_class.new
      column.name = "FLAG"
      column.type = "VARCHAR2"
      column.data_length = 1
      column.data_precision = 0
      column.data_scale = 0
      column.nullable = "N"
      column.data_default = " 'Y' "
      expect(column.extract).to include("DEFAULT 'Y'")
    end

    it "renders an unknown type as-is" do
      column = described_class.new
      column.name = "WHEN"
      column.type = "DATE"
      column.data_length = 0
      column.data_precision = 0
      column.data_scale = 0
      column.nullable = "Y"
      column.data_default = ""
      expect(column.extract).to include("DATE")
    end
  end

  describe ".all" do
    before do
      allow(DbMeta::Oracle::Connection).to receive(:instance).and_return(FakeConnection.instance)
    end

    it "returns column objects with comments" do
      fake = FakeConnection.instance
      cursor_main = FakeCursor.new(rows: [["ID", "NUMBER", 10, 10, 0, "N", ""]])
      cursor_comment = FakeCursor.new(rows: [["primary id"]])
      allow(fake).to receive(:exec).and_return(cursor_main, cursor_comment)

      result = described_class.all(object_name: "EXAMPLE")
      expect(result.size).to eq(1)
      expect(result.first.name).to eq("ID")
      expect(result.first.comment).to eq("primary id")
    end
  end
end
