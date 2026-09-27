## [Unreleased]

### Added

- **`format:`** validator — `format: /regex/` or `{ with:, without: }` form
- **`length:`** validator — `{ is:, minimum:, maximum:, in: }` form; works on strings and arrays
- **`numericality:`** validator — `true` or constraint hash (`only_integer`, `odd`, `even`, `equal_to`, `other_than`, `greater_than`, `greater_than_or_equal_to`, `less_than`, `less_than_or_equal_to`); accepts Integer, Float, and numeric strings
- **`presence:`** validator — fails if nil, empty string, blank string, or empty collection
- **`absence:`** validator — fails if value is present
- **`inclusion:`**, **`exclusion:`**, **`validate:`**, **`validations:`** options on `input`/`output`/`attribute`
- **`coerce:`** option — coerce the value before validation: symbol (`:to_i`), proc, or class with `.parse`; nil is never coerced; runs on input and on output setters
- **`validations:` array** supports `{ with: ValidatorClass, message: '…' }` for inline custom validators with per-entry message overrides
- **`type:` keyword form** — `input :id, type: Integer` as an alternative to the positional form
- **`Interactor::Boolean`** — `:boolean` type constraint accepting `true`/`false`
- **Conditional organize steps** — `if:` and `unless:` on any step; conditions accept a Symbol (method on the organizer) or a Proc
- **Threaded organize steps** — `thread(X)` / `step(X, thread: true)`; all threads are joined before `call` returns
- **Symbol steps in organize** — `organize :my_step` calls `send(:my_step)` on the organizer instance
- **Pair shorthand in organize** — `StepA, { if: :ready? }` as a shorter alternative to `step(StepA, if: :ready?)`
- All validators run per attribute — `result.errors[:key]` may contain multiple strings
- `input`/`output`/`attribute` raise `ArgumentError` for unknown option keys

### Fixed

- `Jobify#sidekiq?` and `#application_job?` now check the resolved job class instead of nonexistent constants

## [0.1.2] - 2026-09-21

- Fixed `Organize::ClassMethods#organized` to correctly inherit parent's organized list when subclass does not define its own

## [0.1.1] - 2026-09-19

- Fixed `Thread.current.thread_variable_get/set` → fiber-local `Thread.current[:key]` to prevent request context collision in rage-rb and other fiber-based servers

## [0.1.0] - 2026-04-24

- Initial release
