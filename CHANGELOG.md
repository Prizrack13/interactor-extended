## [Unreleased]

## [0.1.2] - 2026-09-21

- Fixed `Organize::ClassMethods#organized` to correctly inherit parent's organized list when subclass does not define its own

## [0.1.1] - 2026-09-19

- Fixed `Thread.current.thread_variable_get/set` → fiber-local `Thread.current[:key]` to prevent request context collision in rage-rb and other fiber-based servers

## [0.1.0] - 2026-04-24

- Initial release
