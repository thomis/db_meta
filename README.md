[![Gem Version](https://badge.fury.io/rb/db_meta.svg)](https://badge.fury.io/rb/db_meta)
[![01 - Test](https://github.com/thomis/db_meta/actions/workflows/01_test.yml/badge.svg)](https://github.com/thomis/db_meta/actions/workflows/01_test.yml)
[![02 - Release](https://github.com/thomis/db_meta/actions/workflows/02_release.yml/badge.svg)](https://github.com/thomis/db_meta/actions/workflows/02_release.yml)

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

We welcome contributions to db_meta! Here's how you can help:

1. **Fork the repository** - Create your own fork of the code
2. **Create a feature branch** - Make your changes in a new git branch:
   ```
   git checkout -b my-new-feature
   ```
3. **Make your changes** - Write your code and tests
4. **Run the tests** - Ensure all tests pass:
   ```
   bundle exec rake
   ```
5. **Commit your changes** - Write clear and meaningful commit messages:
   ```
   git commit -am 'Add some feature'
   ```
6. **Push to your branch** - Push your changes to GitHub:
   ```
   git push origin my-new-feature
   ```
7. **Create a Pull Request** - Open a PR from your fork to the main repository

### Guidelines

- Write tests for any new functionality
- Follow the existing code style and conventions
- Update documentation as needed
- Keep commits focused and atomic
- Write clear commit messages

### Reporting Issues

Found a bug or have a feature request? Please open an issue on GitHub with:
- A clear title and description
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Ruby version and environment details

## License
db_meta is released under [Apache License, Version 2.0](https://opensource.org/licenses/Apache-2.0)
