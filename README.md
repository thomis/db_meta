[![Gem Version](https://badge.fury.io/rb/db_meta.svg)](https://badge.fury.io/rb/db_meta)
[![ci](https://github.com/thomis/db_meta/actions/workflows/ci.yml/badge.svg)](https://github.com/thomis/db_meta/actions/workflows/ci.yml)

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

## Supported Ruby Versions

Currently supported and tested ruby versions are:

- 3.4 (EOL 31 Mar 2028)
- 3.3 (EOL 31 Mar 2027)
- 3.2 (EOL 31 Mar 2026)

Ruby versions not tested anymore:

- 3.1 (EOL 31 Mar 2025)
- 3.0 (EOL 31 Mar 2024)
- 2.7 (EOL 31 Mar 2023)
- 2.6 (EOL 31 Mar 2022)

## Planned Features
- Storage and tablespace clause

## Contributing
...

## License
db_meta is released under [Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0)
