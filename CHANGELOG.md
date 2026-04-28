## [0.14.2] - 2026-04-28

### Changed
- Materialized views with a refresh interval are extracted as `START WITH SYSDATE NEXT <interval>` by default, instead of using the live `USER_REFRESH.NEXT_DATE`. The next_date advances on every refresh cycle and made schema diffs noisy across instances. Pass `preserve_mview_schedule: true` to `extract` to keep the original `TO_DATE(...)` form when the exact next-refresh moment matters.

## [0.14.1] - 2026-04-28

### Changed
- Sequences now extract with `START WITH <MINVALUE>` by default (previously `START WITH <LAST_NUMBER>`), so extracts are reproducible and comparable across instances of the same schema. Pass `preserve_sequence_position: true` to `extract` to keep the original live-position behavior.
- `INCREMENT BY` is now emitted for sequences (previously fetched but never written, so non-default increments produced incorrect DDL).

### Fixed
- `Column#extract` now emits an explicit `NOT NULL` for non-nullable columns. Without this, 0.14.0 produced table DDL without any NOT NULL clauses because the previously-relied-on `SYS_*` NOT NULL CHECK constraints are now filtered out as redundant noise.

## [0.14.0] - 2026-04-28

### Changed
- Reuse a single OCI8 logical connection per worker thread for the duration of the fetch instead of acquiring/logging off on every type fetch. Drastically reduces session attach/detach traffic against the connection pool, which avoids the per-attach overhead (and the 23c Instant Client byte-leak symptom) on long extracts.
- Batch-load constraint metadata via two bulk queries against `USER_CONSTRAINTS` and `USER_CONS_COLUMNS` once before the parallel object fetch, and have `Constraint#fetch` read from an in-memory cache. Removes 2-3 round-trips per constraint.
- Constraints with Oracle-generated `SYS_*` names are now emitted without an explicit `CONSTRAINT <name>` clause, so DDL diffs across instances aren't dominated by name churn. User-given names are preserved.
- Redundant `SYS_*` NOT NULL CHECK constraints (whose condition is just `"COL" IS NOT NULL`) are filtered out — the column-level NOT NULL in the table DDL already covers them.
- Fixed `View#fetch` to reuse the acquired connection (previously called `Connection.instance.get` twice, leaking a logical connection per view).
- Fixed `View#extract` crash when a view has columns without comments (`column.comment.size` on nil).
- Fixed `Table#fetch` ensure logic (was `rescue` instead of `ensure`).
- Fixed `Column.all` typo (`loggoff` → cleanup no longer needed).

### Added
- README troubleshooting section for macOS / Apple Silicon: short tip covering both the 23c OID lookup hang and the `libclntsh` ↔ OpenLDAP symbol-clash, with the shared `tnsnames.ora` + `NAMES.DIRECTORY_PATH=(TNSNAMES, EZCONNECT)` fix and links to the relevant ruby-oci8 / Oracle docs.
- Significantly expanded test coverage (49 → 125 examples; line coverage 58.94% → ~86%).
- Added Ruby 4.0 to the supported/tested matrix.

### Removed
- Dropped Ruby 3.2 from the actively tested matrix (EOL 31 Mar 2026).

## [0.13.1] - 2025-11-09

### Added
- Trusted Publisher

### Changed
- Updated development dependencies

## [0.13.0] - 2024-12-25

### Changed
- Support for Ruy 3.4

## [0.12.0] - 2024-06-15

### Changed
- Fix Column.new to pass no arguments

## [0.11.0] - 2024-06-15

### Changed
- Update depenencies

## [0.10.0] - 2024-03-17

### Changed
- Update depenencies

## [0.9.0] - 2024-02-21

### Changed
- Update depenencies

## [0.8.0] - 2024-01-12

### Changed
- Update depenencies

## [0.7.1] - 2022-12-31

### Changed
- Update depenencies

## [0.7.0] - 2022-11-20

### Added
- Use GitHub actions
- Use Ruby style guide and linter
- Use Dependabot to keep dependencies up to date
- Use test coverage
- Have more rspec tests

### Changed
- Remove travis integration
- Update depenencies
- Fix rspec tests

## [0.6.2] - 2021-06-29

### Changed
- Fix check when column.comment is nil

## [0.6.2] - 2021-07-21

### Changed
- Update ruby versions to test

## [0.6.1] - 2021-05-01

### Changed
- Update gem dependencies

## [0.6.0] - 2021-02-23

### Changed
- Escape "'" and ";" for clob multiline strings (supports empty lines)

## [0.5.0] - 2021-02-22

### Changed
- Update gem dependencies
- Number of thread settings
- Ruby style guide applied through standradrb gem

## [0.4.0] - 2020-02-28

### Changed
- Update of gem dependencies

## [0.3.1] - 2019-06-19

### Changed
- Extract table data when primary key spans over multiple columns
- Update bundler

## [0.3.0] - 2018-08-17

### Changed
- Update license

## [0.2.7] - 2018-08-17

### Added
- Function based indexes

## [0.2.7] - 2018-02-27

### Changed
* ruby-oci8 gem to 2.2.5.1
* rake gem to 12.3.0

## [0.2.6] - 2018-02-16

### Changed
- Typo synonym
- Used force => true when deleting a queue table

## [0.2.5] - 2017-11-24

### Changed
- Typo max_retires =>  max_retries

## [0.2.4] - 2017-11-24

### Changed
- Sort order: ENQUEUE_TIME => ENQ_TIME

## [0.2.2] - 2017-11-15

### Changed
- create or replace for functions and procedures

## [0.2.1] - 2017-11-07

### Changed
- Update dependencies rspec, bundler, ruby-oci8
- Travis settings

## [0.1.3] - 2017-08-29

### Added
- very early version where most of the core oracle types are supported
- ability to extract core data

## [0.1.2] - 2017-08-03

### Added
- another very early version

## [0.1.1] - 2016-05-10

### Added
- very early development version

## [0.1.0] - 2016-05-10

### Added
- initial setup
