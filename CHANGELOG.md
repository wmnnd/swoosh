## Changelog

## v0.2.0-dev
### Added
* Add support for runtime configuration using {:system, "ENV_VAR"} tuples
* Add support for passing config as an argument to deliver/2

### Changed
* Adapters have consistent succesfful return value ({:ok, term})
* Only compile `Plug.Swoosh.MailboxPreview` if `Plug` is loaded
* Relax Poison version requirement (`~> 1.5 or ~> 2.0`)

### Removed
* Remove `cowboy` and `plug` from the list of applications as they are optional
dependencies

## v0.1.0

* Initial version
