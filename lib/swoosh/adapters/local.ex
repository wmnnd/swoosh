defmodule Swoosh.Adapters.Local do
  @moduledoc ~S"""
  An adapter that stores the email locally.

  This is especially useful in development to avoid sending real emails. You can
  read the emails you have sent using functions in the
  [Swoosh.InMemoryMailbox](Swoosh.InMemoryMailbox.html) or the
  [Plug.Swoosh.MailboxPreview](Plug.Swoosh.MailboxPreview.html) plug.

  ## Example

      # config/config.exs
      config :sample, Sample.Mailer,
	adapter: Swoosh.Adapters.Local

      # lib/sample/mailer.ex
      defmodule Sample.Mailer do
	use Swoosh.Mailer, otp_app: :sample
      end
  """

  @behaviour Swoosh.Adapter

  def deliver(%Swoosh.Email{} = email, _config) do
    Swoosh.InMemoryMailbox.push(email)
  end
end
