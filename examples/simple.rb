require "rubygems"
require "db_meta"

meta = DbMeta::DbMeta.new(username: "guest", password: "guest", instance: "dbmeta")
meta.fetch
meta.extract
