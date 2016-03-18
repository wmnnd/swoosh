# Swoosh

Swoosh is like ActiveMailer, but it's functional.  And it's more focused.  And it's got a nice API.  Okay, it's nothing
like ActiveMailer.  But it will let you send email from your Elixir applications conveniently, through a number of
services.  Just choose the adapter that suits your needs and you will be sending email in a matter of minutes.

Heck, you can use several services simultaneously if you choose.


## Installation

1. Add swoosh to your list of dependencies in `mix.exs`:

      def deps do
        [{:swoosh, "~> 0.0.1"}]
      end

2. Ensure swoosh is started before your application:

      def application do
        [applications: [:swoosh]]
      end


## Getting started

Define a mailer...

```elixir
# lib/my_app/mailer.ex
defmodule MyApp.Mailer do
  use Swoosh.Mailer, otp_app: :my_app
end
```

Configure it:

```elixir
# config/config.exs
config :my_app, MyApp.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "SG.x.x"
```

Then send an email...

```elixir
email =
  %Swoosh.Email{}
  |> to({"T Stark", "tony@stark.com"})
  |> from({"Dr B Banner", "hulk@smash.com"})
  |> subject("Hell, Avengers!")
  |> html_body("<h1>Hello</h1>")
  |> text_body("Hello\n")

MyApp.Mailer.deliver(email)
```

## Documentation

Documentation is written into the library, you will find it in the source code, accessible from `iex` and of course, it
all gets published to [hexdocs](http://hexdocs.pm/swoosh).

## Contributing

We are greatful for any contributions, please look at the [Code of Conduct](CODE_OF_CONDUCT.md) and
[Contributing guidelines](CONTRIBUTING.md) to find out more.  We use GitHub Issues to keep track of features and bugs, usually
there will be a milestone for each release, so you can see what is coming next.

## LICENSE

See [LICENSE](https://github.com/swoosh/swoosh/blob/master/LICENSE.txt)
