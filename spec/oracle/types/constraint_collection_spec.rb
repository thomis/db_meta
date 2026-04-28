require "spec_helper"

RSpec.describe DbMeta::Oracle::ConstraintCollection do
  let(:collection) { described_class.new(name: "ALL FK", type: "CONSTRAINT") }

  let(:fk) do
    cache = DbMeta::Oracle::Constraint.class_variable_get(:@@cache)
    cache["FK_A"] = {
      constraint_type: "FOREIGN KEY",
      table_name: "CHILD_A",
      search_condition: nil,
      r_constraint_name: "PK_PARENT",
      delete_rule: nil,
      columns: ["PID"]
    }
    cache["PK_PARENT"] = {
      constraint_type: "PRIMARY KEY",
      table_name: "PARENT",
      search_condition: nil,
      r_constraint_name: nil,
      delete_rule: nil,
      columns: ["ID"]
    }
    c = DbMeta::Oracle::Constraint.new("OBJECT_TYPE" => "CONSTRAINT", "OBJECT_NAME" => "FK_A")
    c.fetch
    c
  end

  before { DbMeta::Oracle::Constraint.reset_cache }

  it "is empty by default" do
    expect(collection.empty?).to eq(true)
  end

  it "is not a system object" do
    expect(collection.system_object?).to eq(false)
  end

  it "ddl_drop is a comment about table cascade" do
    expect(collection.ddl_drop).to include("automatically be dropped")
  end

  it "appends and extracts grouped by table" do
    collection << fk
    output = collection.extract
    expect(output).to include("ALL FK")
    expect(output).to include("CHILD_A")
    expect(output).to include("FOREIGN KEY")
  end
end
