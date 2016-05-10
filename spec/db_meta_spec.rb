require 'spec_helper'

describe DbMeta do
  it 'has a version number' do
    expect(DbMeta::VERSION).not_to be nil
  end

  it 'validates allowed database types' do
    expect(DbMeta::DATABASE_TYPES.size).to eq(1)
    expect(DbMeta::DATABASE_TYPES[0]).to eq(:oracle)
  end

  it 'expects a username' do
    expect{ DbMeta::DbMeta.new }.to raise_error(RuntimeError, 'username is mandatory, pass a username argument during initialization')
  end

  it 'expects a password' do
    expect { DbMeta::DbMeta.new(username: 'a_username') }.to raise_error(RuntimeError, 'password is mandatory, pass a password argument during initialization')
  end

  it 'expects an instance' do
    expect { DbMeta::DbMeta.new(username: 'a_username', password: 'a_password') }.to raise_error(RuntimeError, 'instance is mandatory, pass a instance argument during initialization')
  end

  it 'expects a valid database type' do
    expect { DbMeta::DbMeta.new(username: 'a_username', password: 'a_password', instance: 'an_instance', database_type: :unknown) }.to raise_error(RuntimeError, 'allowed database types are [oracle], but provided was [unknown]')
  end

end
