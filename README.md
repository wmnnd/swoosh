# Swoosh

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add swoosh to your list of dependencies in `mix.exs`:

        def deps do
          [{:swoosh, "~> 0.0.1"}]
        end

  2. Ensure swoosh is started before your application:

        def application do
          [applications: [:swoosh]]
        end

## TODO

* Mail structure
    |> from()
    |> to()
    |> to()
    |> cc()
    |> bcc()
    |> attach()
*Adapters
  * Local (can be used for tests)
  * SMTP
  * Sendmail?
  * APIs
    * Sendgrid
    * Mailgun
    * Mandrill?
    * Postmark
    * MailChimp
    * mailjet
    * socketlabs
    * ElasticEmail
    * postageapp
* Easy testing
* Delivery strategies
  * Now
  * Later
  * Retries/backoff
* Platform specific features
  * Scheduled sends
  * Templates
* Attachments
* Revisit plug dependency
