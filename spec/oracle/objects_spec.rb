require "spec_helper"

RSpec.describe DbMeta::Oracle::Objects do
  let(:objects) { described_class.new }

  let(:table) {
    DbMeta::Oracle::Table.new("OBJECT_TYPE" => "TABLE", "OBJECT_NAME" => "T1")
  }

  let(:invalid_function) {
    DbMeta::Oracle::Function.new(
      "OBJECT_TYPE" => "FUNCTION", "OBJECT_NAME" => "BROKEN", "STATUS" => "INVALID"
    )
  }

  let(:system_table) {
    DbMeta::Oracle::Table.new("OBJECT_TYPE" => "TABLE", "OBJECT_NAME" => "SYS$TBL")
  }

  it "tracks summary, system objects, and invalids on append" do
    objects << table
    objects << invalid_function
    objects << system_table

    summary = {}
    objects.summary_each { |type, count| summary[type] = count }
    expect(summary["TABLE"]).to eq(2)
    expect(summary["FUNCTION"]).to eq(1)

    expect(objects.summary_system_object["TABLE"]).to eq(1)
    expect(objects.invalids?).to eq(true)

    invalid_types = []
    objects.invalid_each { |type, _items| invalid_types << type }
    expect(invalid_types).to include("FUNCTION")
  end

  it "merges synonyms into a collection object" do
    syn = DbMeta::Oracle::Synonym.new("OBJECT_TYPE" => "SYNONYM", "OBJECT_NAME" => "S1")
    objects << syn

    objects.merge_synonyms

    types = []
    objects.summary_each { |type, _count| types << type }
    expect(types).to include("SYNONYM")
  end

  it "merges grants into a collection object" do
    grant = DbMeta::Oracle::Grant.new(
      "OBJECT_TYPE" => "GRANT",
      "OBJECT_NAME" => "G,O,T,O,SELECT,NO"
    )
    allow(FakeConnection.instance).to receive(:username).and_return("O")
    grant.fetch(connection_class: FakeConnection)

    objects << grant
    objects.merge_grants

    types = []
    objects.summary_each { |type, _count| types << type }
    expect(types).to include("GRANT")
  end

  it "embeds indexes into their owning table" do
    objects << table
    index = DbMeta::Oracle::Index.new("OBJECT_TYPE" => "INDEX", "OBJECT_NAME" => "I1")
    index.instance_variable_set(:@table_name, "T1")
    objects << index

    objects.embed_indexes
    expect(table.instance_variable_get(:@indexes)).to include(index)
  end

  it "embeds triggers and falls back to default extract when no table" do
    objects << table

    trig_with_table = DbMeta::Oracle::Trigger.new("OBJECT_TYPE" => "TRIGGER", "OBJECT_NAME" => "TR1")
    trig_with_table.table_name = "T1"
    objects << trig_with_table

    trig_orphan = DbMeta::Oracle::Trigger.new("OBJECT_TYPE" => "TRIGGER", "OBJECT_NAME" => "TR2")
    trig_orphan.table_name = "MISSING"
    objects << trig_orphan

    objects.embed_triggers
    expect(table.instance_variable_get(:@triggers)).to include(trig_with_table)
    expect(trig_orphan.extract_type).to eq(:default)
  end

  it "default_each yields default-type, non-system objects in type order" do
    objects << table
    objects << system_table

    yielded = []
    objects.default_each { |o| yielded << o.name }
    expect(yielded).to eq(["T1"])
  end

  it "reverse_default_each yields in reverse type order" do
    objects << table
    func = DbMeta::Oracle::Function.new("OBJECT_TYPE" => "FUNCTION", "OBJECT_NAME" => "F1")
    objects << func

    yielded = []
    objects.reverse_default_each { |o| yielded << o.name }
    expect(yielded).to include("T1", "F1")
  end
end
