require 'spec_helper'

describe DbMeta do
  it 'has a version number' do
    expect(DbMeta::VERSION).not_to be nil
  end

  it 'expects a username' do
    meta = DbMeta::DbMeta.new
    expect{ meta.fetch }.to raise_error(RuntimeError, 'username is mandatory, pass a username argument during initialization')
  end

  it 'expects a password' do
    meta = DbMeta::DbMeta.new(username: 'a_username')
    expect{ meta.fetch }.to raise_error(RuntimeError, 'password is mandatory, pass a password argument during initialization')
  end

  it 'expects an instance' do
    meta = DbMeta::DbMeta.new(username: 'a_username', password: 'a_password')
    expect{ meta.fetch }.to raise_error(RuntimeError, 'instance is mandatory, pass a instance argument during initialization')
  end

  it 'expects a valid database type' do
    meta = DbMeta::DbMeta.new(username: 'a_username', password: 'a_password', instance: 'an_instance', database_type: :unknown)
    expect{ meta.fetch }.to raise_error(RuntimeError, 'allowed database types are [oracle], but provided was [unknown]')
  end

end
