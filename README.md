# Swoosh

[![Build Status](https://travis-ci.org/swoosh/swoosh.svg?branch=master)](https://travis-ci.org/swoosh/swoosh)
[![Inline docs](http://inch-ci.org/github/swoosh/swoosh.svg?branch=master&style=flat)](http://inch-ci.org/github/swoosh/swoosh)

Compose, deliver and test your emails easily in Elixir.

We have applied the lessons learned from projects like Plug, Ecto and Phoenix in designing clean and composable APIs,
with clear separation of concerns between modules.

## Getting started

```elixir
# In your config/config.exs file
config :sample, Sample.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "SG.x.x"

# In your application code
defmodule Sample.Mailer do
  use Swoosh.Mailer, otp_app: :my_app
end

defmodule Sample.UserEmail do
  import Swoosh.Email

  def welcome(user) do
    %Swoosh.Email{}
    |> to({user.name, user.email})
    |> from({"Dr B Banner", "hulk@smash.com"})
    |> subject("Hello, Avengers!")
    |> html_body("<h1>Hello #{user.name}</h1>")
    |> text_body("Hello #{user.name}\n")
  end
end

# In an IEx session
Sample.UserEmail.welcome(%{name: "Tony Stark", email: "tony@stark.com"}) |> Mailer.deliver

# Or in a Phoenix controller
defmodule Sample.UserController do
  use Phoenix.Controller
  alias Sample.UserEmail
  alias Sample.Mailer

  def create(conn, params) do
    user = # create user logic
    UserEmail.welcome(user) |> Mailer.deliver
  end
end

```
## Installation

1. Add swoosh to your list of dependencies in `mix.exs`:

      ```elixir
      def deps do
        [{:swoosh, "~> 0.1.0"}]
      end
      ```

2. Ensure swoosh is started before your application:

      ```elixir
      def application do
        [applications: [:swoosh]]
      end
      ```

## Adapters

Swoosh supports the most popular transactional email providers out of the box and also has an SMTP adapter. Below is a

Provider   | Swoosh adapter
:----------| :------------------------
SMTP       | Swoosh.Adapters.SMTP
Sendgrid   | Swoosh.Adapters.Sendgrid
Mandrill   | Swoosh.Adapters.Mandrill
Mailgun    | Swoosh.Adapters.Mailgun
Postmark   | Swoosh.Adapters.Postmark

Configure which adapter you want to use by updating your `config/config.exs` file:

```elixir
config :sample, Sample.Mailer,
  adapter: Swoosh.Adapters.SMTP
  # adapter config (api keys, etc.)
```

Adding new adapters is super easy and we are definitely looking for contributions on that front. Get in touch if you want
to help!

## Phoenix integration

If you are looking to use Swoosh in your Phoenix project, make sure to check out the
[phoenix_swoosh](https://github.com/swoosh/phoenix_swoosh) project. It contains a set of functions that make it easy to
render the text and HTML bodies using Phoenix views, templates and layouts.

Taking the example from above again, your code would look something like this:

```elixir
# web/templates/layout/email.html.eex
<html>
  <head>
    <title><%= @email.subject %></title>
  </head>
  <body>
    <%= render @view_module, @view_template, assigns %>
  </body>
</html>

# web/templates/email/welcome.html.eex
<div>
  <h1>Welcome to Sample, <%= @username %>!</h1>
</div>

# web/emails/user_email.ex
defmodule Sample.UserEmail do
  use Phoenix.Swoosh, view: Sample.EmailView, layout: {Sample.LayoutView, :email}

  def welcome(user) do
    %Swoosh.Email{}
    |> to({user.name, user.email})
    |> from({"Dr B Banner", "hulk@smash.com"})
    |> subject("Hello, Avengers!")
    |> template_body("welcome.html", %{username: user.username})
  end
end
```

Feels familiar doesn't it? Head to the [phoenix_swoosh](https://github.com/swoosh/phoenix_swoosh) repo for more details.

## Testing

You can import the `Swoosh.Test` module in your tests to assert whether emails where sent or not.

```elixir
defmodule Sample.UserTest do
  use ExUnit.Case, async: true

  test "send email on user signup" do
    user = create_user(%{username: "ironman", email: "tony@stark.com"})
    assert_email_sent %Swoosh.Email{to: "tony@stark.com", subject: "Hello, ironman!"}
  end
end
```

## Documentation

Documentation is written into the library, you will find it in the source code, accessible from `iex` and of course, it
all gets published to [hexdocs](http://hexdocs.pm/swoosh).

## Contributing

We are grateful for any contributions. Before you submit an issue or a pull request, remember to:

* Look at our [Contributing guidelines](CONTRIBUTING.md)
* Not use the issue tracker for help or support requests (try StackOverflow, IRC or Slack instead)
* Do a quick search in the issue tracker to make sure the issues hasn't been reported yet.
* Look and follow the [Code of Conduct](CODE_OF_CONDUCT.md). Be nice and have fun!

### Running tests

Clone the repo and fetch its dependencies:

```
$ git clone https://github.com/swoosh/swoosh.git
$ cd swoosh
$ mix deps.get
$ mix test
```

### Building docs

```
$ MIX_ENV=docs mix docs
```

## LICENSE

See [LICENSE](https://github.com/swoosh/swoosh/blob/master/LICENSE.txt)
