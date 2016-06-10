defmodule Swoosh.Adapters.Test do
  @moduledoc ~S"""
  An adapter that sends emails as messages to the current process.

  This is meant to be used during tests and works with the assertions found in
  the [Swoosh.TestAssertions](Swoosh.TestAssertions.html) module.

  ## Example

      # config/test.exs
      config :sample, Sample.Mailer,
        adapter: Swoosh.Adapters.Test

      # lib/sample/mailer.ex
      defmodule Sample.Mailer do
        use Swoosh.Mailer, otp_app: :sample
      end
  """

  @behaviour Swoosh.Adapter

  def validate_config(_config), do: {:ok}

  def deliver(email, _config) do
    send(self(), {:email, email})
    {:ok, %{}}
  end
end
