[![Gem Version](https://badge.fury.io/rb/db_meta.svg)](https://badge.fury.io/rb/db_meta)

# Welcome to db_meta
Database meta and core data extraction.

## Is it production ready?

Well, I would not say, but I am using it already for my database development work where the gem covers my needs. Be careful and check details. Please create an issue when you think that someting is wrong or missing.

## Installation
via Gemfile
```
gem 'db_meta'
```

via command prompt
```
gem install db_meta
```

## Example
```
require 'rubygems'
require 'db_meta'

meta = DbMeta::DbMeta.new(username: 'a_username', password: 'a_password', instance: 'an_instance')
meta.fetch
meta.extract
```

## Supported Databases
- Oracle

### Supported Oracle object types
- Table (including Trigger, Constraint, Index)
- View and Materialized Views
- Grant
- Function, Procedures, Packages
- Type
- Synonym
- Database Link
- Queue
- Function based Indexes
- more to come...

## Planned Features
- Storage and tablespace clause

## Contributing
...

## License
db_meta is released under [Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0)
