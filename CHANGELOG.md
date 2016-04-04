## Changelog

## v0.3.0-dev
### Added
* Add `Swoosh.Email.new/1` function to create `Swoosh.Email{}` struct.

## [v0.2.0] - 2016-03-31
### Added
* Add support for runtime configuration using {:system, "ENV_VAR"} tuples
* Add support for passing config as an argument to deliver/2

### Changed
* Adapters have consistent successful return value ({:ok, term})
* Only compile `Plug.Swoosh.MailboxPreview` if `Plug` is loaded
* Relax Poison version requirement (`~> 1.5 or ~> 2.0`)

### Removed
* Remove `cowboy` and `plug` from the list of applications as they are optional
dependencies

## [v0.1.0]

* Initial version
