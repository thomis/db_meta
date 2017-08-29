[![Gem Version](https://badge.fury.io/rb/db_meta.svg)](https://badge.fury.io/rb/db_meta)
[![Dependency Status](https://gemnasium.com/badges/github.com/thomis/db_meta.svg)](https://gemnasium.com/github.com/thomis/db_meta)

# Welcome to db_meta
Database meta and core data extraction.

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
- more to come...

## Planned Features
...

## Contributing
...

## License
db_meta is released under [Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0)
