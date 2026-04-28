[![Gem Version](https://badge.fury.io/rb/db_meta.svg)](https://badge.fury.io/rb/db_meta)
[![01 - Test](https://github.com/thomis/db_meta/actions/workflows/01_test.yml/badge.svg)](https://github.com/thomis/db_meta/actions/workflows/01_test.yml)
[![02 - Release](https://github.com/thomis/db_meta/actions/workflows/02_release.yml/badge.svg)](https://github.com/thomis/db_meta/actions/workflows/02_release.yml)

# db_meta

Extract Oracle schema metadata and core data as SQL DDL files.

`db_meta` connects to an Oracle schema and writes out DDL for every object (tables, views, indexes, constraints, packages, sequences, synonyms, grants, …), plus optional `INSERT` scripts for reference/lookup data. The output is a folder of `.sql` files organized by object type — suitable for checking into version control, diffing across environments, or seeding a fresh schema.

## Status

Used in day-to-day database development by the author. It covers the most common Oracle object types but is not exhaustive — exotic features (advanced storage clauses, partitioning details, etc.) may be missing or simplified. Spot-check the output before relying on it for a migration, and please open an issue if you hit something that's wrong or missing.

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

## Output conventions

A few decisions worth knowing about, especially if you compare extracts across instances:

- **Auto-generated `SYS_*` constraint names are stripped from the output.** Oracle invents names like `SYS_C0012345` for unnamed constraints, and those names differ between instances — making schema diffs noisy. Constraints with a `SYS_*` name are emitted without an explicit `CONSTRAINT <name>` clause; on import, Oracle just generates a fresh name. User-given constraint names are preserved as-is.
- **Redundant `NOT NULL` CHECK constraints are omitted.** Oracle exposes column-level `NOT NULL` both as a column attribute and as a `SYS_*` CHECK constraint with a body of `"COL" IS NOT NULL`. The column-level form is already in the table DDL, so the duplicate CHECK is filtered out.

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

- 4.0 (EOL 31 Mar 2029)
- 3.4 (EOL 31 Mar 2028)
- 3.3 (EOL 31 Mar 2027)

Ruby versions not tested anymore:

- 3.2 (EOL 31 Mar 2026)
- 3.1 (EOL 31 Mar 2025)
- 3.0 (EOL 31 Mar 2024)
- 2.7 (EOL 31 Mar 2023)
- 2.6 (EOL 31 Mar 2022)

## Planned Features
- Storage and tablespace clause

## Troubleshooting (macOS / Apple Silicon)

If `OCI8.new` hangs for ~10s, prints "byte leak" gibberish, or crashes with `ldap_first_entry: Assertion …`, the issue is almost always that the Instant Client is trying to use LDAP/OID for database name resolution. The fix is the same in both cases: tell Oracle to use a local `tnsnames.ora` instead of LDAP. Create `~/opt/oracle/admin/tnsnames.ora` with your DB alias and `~/opt/oracle/admin/sqlnet.ora` containing `NAMES.DIRECTORY_PATH=(TNSNAMES, EZCONNECT)`, then `export TNS_ADMIN=$HOME/opt/oracle/admin`.

For background and the `libclntsh` ↔ OpenLDAP symbol-clash variant (caused by Oracle's bundled LDAP client and Homebrew's OpenLDAP both loading into the same Ruby process), see:

- [ruby-oci8 #32 — OCI8 hangs when switching to LDAP](https://github.com/kubo/ruby-oci8/issues/32)
- [ruby-oci8 #41 — Assertion failure using LDAP](https://github.com/kubo/ruby-oci8/issues/41)
- [Oracle Instant Client FAQ](https://www.oracle.com/database/technologies/instant-client/faqs.html)

## Publishing

This project uses [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) to securely publish gems to RubyGems.org. Trusted Publishing eliminates the need for long-lived API tokens by using OpenID Connect (OIDC) to establish a trusted relationship between GitHub Actions and RubyGems.org.

With Trusted Publishing configured, gem releases are automatically published to RubyGems when the release workflow runs, providing a more secure and streamlined publishing process.

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
