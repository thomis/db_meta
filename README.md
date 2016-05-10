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

## Supported Database types
- Oracle

### Suported Oracle object types
- Table
- more to come...

## Contributing

## License
db_meta is released under (Apache License, Version 2.0)[https://opensource.org/licenses/Apache-2.0]
