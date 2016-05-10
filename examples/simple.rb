require 'rubygems'
require 'db_meta'

meta = DbMeta::DbMeta.new(username: 'a_username', password: 'a_password', instance: 'an_instance')
meta.fetch
