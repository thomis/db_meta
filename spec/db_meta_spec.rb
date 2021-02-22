require "spec_helper"

meta_args = {
  username: "a_username",
  password: "a_password",
  instance: "an_instance"
}

class Example < DbMeta::Abstract
  register_type(:example)
end

describe DbMeta do
  it "has a version number" do
    expect(DbMeta::VERSION).not_to be nil
  end

  it "validates allowed database types" do
    expect(DbMeta::DATABASE_TYPES.size).to eq(1)
    expect(DbMeta::DATABASE_TYPES[0]).to eq(:oracle)
  end

  it "expects a username" do
    expect { DbMeta::DbMeta.new }.to raise_error(RuntimeError, "username is mandatory, pass a username argument during initialization")
  end

  it "expects a password" do
    expect { DbMeta::DbMeta.new(username: "a_username") }.to raise_error(RuntimeError, "password is mandatory, pass a password argument during initialization")
  end

  it "expects an instance" do
    expect { DbMeta::DbMeta.new(username: "a_username", password: "a_password") }.to raise_error(RuntimeError, "instance is mandatory, pass a instance argument during initialization")
  end

  it "expects a valid database type" do
    expect { DbMeta::DbMeta.new(username: "a_username", password: "a_password", instance: "an_instance", database_type: :unknown) }.to raise_error(RuntimeError, "allowed database types are [oracle], but provided was [unknown]")
  end

  it "creates an valid instance" do
    expect {
      DbMeta::DbMeta.new(meta_args)
    }.not_to raise_error
  end

  it "fails with unknown abstract type" do
    expect {
      DbMeta::Abstract.from_type(:unkown, meta_args)
    }.to raise_error(RuntimeError, "Abstract type [unkown] is unknown")
  end

  it "fails with missing instance methods" do
    meta = DbMeta::Abstract.from_type(:example, meta_args)

    expect {
      meta.fetch
    }.to raise_error(RuntimeError, "Needs to be implemented in derived class")

    expect {
      meta.extract
    }.to raise_error(RuntimeError, "Needs to be implemented in derived class")
  end

  it "failes to extract with unknown format" do
    meta = DbMeta::Abstract.from_type(:oracle, meta_args)
    expect {
      meta.extract(format: :unknown)
    }.to raise_error(RuntimeError, "Format [unknown] is not supported")
  end
end
