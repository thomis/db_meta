require "spec_helper"

RSpec.describe DbMeta::Oracle::Constraint do
  let!(:constraint) {
    DbMeta::Oracle::Constraint.new("OBJECT_TYPE" => "CONSTRAINT", "OBJECT_NAME" => "PK_EXAMPLE")
  }

  before { DbMeta::Oracle::Constraint.reset_cache }

  it "has drop statement" do
    expect(constraint.ddl_drop).to eq("DROP CONSTRAINT PK_EXAMPLE;")
  end

  it "is not a system object" do
    expect(constraint.system_object?).to eq(false)
  end

  it "preloads metadata in two bulk queries" do
    instance = FakeConnection.instance.get
    expect(instance).to receive(:exec).twice.and_return(
      FakeCursor.new(hash_rows: [
        {
          "CONSTRAINT_NAME" => "PK_EXAMPLE",
          "CONSTRAINT_TYPE" => "P",
          "TABLE_NAME" => "EXAMPLE",
          "SEARCH_CONDITION" => nil,
          "R_CONSTRAINT_NAME" => nil,
          "DELETE_RULE" => nil
        }
      ]),
      FakeCursor.new(hash_rows: [
        {"CONSTRAINT_NAME" => "PK_EXAMPLE", "COLUMN_NAME" => "ID", "POSITION" => 1}
      ])
    )

    DbMeta::Oracle::Constraint.preload(connection_class: FakeConnection)

    expect(DbMeta::Oracle::Constraint.cache).to have_key("PK_EXAMPLE")
    entry = DbMeta::Oracle::Constraint.cache["PK_EXAMPLE"]
    expect(entry[:constraint_type]).to eq("PRIMARY KEY")
    expect(entry[:table_name]).to eq("EXAMPLE")
    expect(entry[:columns]).to eq(["ID"])
  end

  it "fetches from cache and extracts a primary key" do
    DbMeta::Oracle::Constraint.class_variable_get(:@@cache)["PK_EXAMPLE"] = {
      constraint_type: "PRIMARY KEY",
      table_name: "EXAMPLE",
      search_condition: nil,
      r_constraint_name: nil,
      delete_rule: nil,
      columns: ["ID"]
    }

    constraint.fetch
    expect(constraint.constraint_type).to eq("PRIMARY KEY")
    expect(constraint.table_name).to eq("EXAMPLE")
    expect(constraint.columns).to eq(["ID"])

    stmt = <<~EOS.chomp
      ALTER TABLE EXAMPLE ADD (
        CONSTRAINT PK_EXAMPLE
        PRIMARY KEY (ID)
        ENABLE VALIDATE
      );
    EOS
    expect(constraint.extract).to eq(stmt + "\n")
  end

  it "skips Oracle-generated NOT NULL CHECK constraints during preload" do
    instance = FakeConnection.instance.get
    expect(instance).to receive(:exec).twice.and_return(
      FakeCursor.new(hash_rows: [
        {
          "CONSTRAINT_NAME" => "SYS_C0012345",
          "CONSTRAINT_TYPE" => "C",
          "TABLE_NAME" => "EXAMPLE",
          "SEARCH_CONDITION" => '"ID" IS NOT NULL',
          "R_CONSTRAINT_NAME" => nil,
          "DELETE_RULE" => nil
        },
        {
          "CONSTRAINT_NAME" => "PK_EXAMPLE",
          "CONSTRAINT_TYPE" => "P",
          "TABLE_NAME" => "EXAMPLE",
          "SEARCH_CONDITION" => nil,
          "R_CONSTRAINT_NAME" => nil,
          "DELETE_RULE" => nil
        }
      ]),
      FakeCursor.new(hash_rows: [
        {"CONSTRAINT_NAME" => "PK_EXAMPLE", "COLUMN_NAME" => "ID", "POSITION" => 1}
      ])
    )

    DbMeta::Oracle::Constraint.preload(connection_class: FakeConnection)

    expect(DbMeta::Oracle::Constraint.cache).not_to have_key("SYS_C0012345")
    expect(DbMeta::Oracle::Constraint.cache).to have_key("PK_EXAMPLE")
  end

  it "keeps SYS_ CHECK constraints whose condition is not a plain NOT NULL" do
    expect(
      DbMeta::Oracle::Constraint.redundant_not_null?("SYS_C001", "CHECK", "AMOUNT > 0")
    ).to eq(false)
    expect(
      DbMeta::Oracle::Constraint.redundant_not_null?("SYS_C001", "CHECK", '"ID" IS NOT NULL')
    ).to eq(true)
  end

  it "omits the CONSTRAINT name line for system-generated names" do
    DbMeta::Oracle::Constraint.class_variable_get(:@@cache)["SYS_C00099"] = {
      constraint_type: "PRIMARY KEY",
      table_name: "EXAMPLE",
      search_condition: nil,
      r_constraint_name: nil,
      delete_rule: nil,
      columns: ["ID"]
    }

    sys_constraint = DbMeta::Oracle::Constraint.new(
      "OBJECT_TYPE" => "CONSTRAINT", "OBJECT_NAME" => "SYS_C00099"
    )
    sys_constraint.fetch
    output = sys_constraint.extract
    expect(output).not_to include("CONSTRAINT SYS_C00099")
    expect(output).to include("PRIMARY KEY (ID)")
  end

  it "resolves referential constraint for a foreign key from cache" do
    cache = DbMeta::Oracle::Constraint.class_variable_get(:@@cache)
    cache["FK_CHILD"] = {
      constraint_type: "FOREIGN KEY",
      table_name: "CHILD",
      search_condition: nil,
      r_constraint_name: "PK_PARENT",
      delete_rule: "CASCADE",
      columns: ["PARENT_ID"]
    }
    cache["PK_PARENT"] = {
      constraint_type: "PRIMARY KEY",
      table_name: "PARENT",
      search_condition: nil,
      r_constraint_name: nil,
      delete_rule: nil,
      columns: ["ID"]
    }

    fk = DbMeta::Oracle::Constraint.new("OBJECT_TYPE" => "CONSTRAINT", "OBJECT_NAME" => "FK_CHILD")
    fk.fetch

    expect(fk.constraint_type).to eq("FOREIGN KEY")
    expect(fk.referential_constraint.table_name).to eq("PARENT")
    expect(fk.referential_constraint.columns).to eq(["ID"])
    expect(fk.extract).to include("REFERENCES PARENT (ID)")
    expect(fk.extract).to include("ON DELETE CASCADE")
  end
end
