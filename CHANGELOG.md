## Changelog

## v0.3.0 - 2016-04-20
### Added
* Add `Swoosh.Email.new/1` function to create `Swoosh.Email{}` struct.
* `Swoosh.TestAssertions.assert_email_sent/1` now supports asserting on specific email params.

### Changed
* Remove the need for `/` when setting the Mailgun adapter domain config.
* `Plug.Swoosh.MailboxPreview` now formats email fields in a more friendlier way.

### Fixed
* Use the sender's name in the `From` header with the Mailgun adapter.
* Send custom headers set in `%Swoosh.Email{}.headers` when using the SMTP adapter.
* Use the "Sender" header before the "From" header as the "MAIL FROM" when using the SMTP adapter.

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
