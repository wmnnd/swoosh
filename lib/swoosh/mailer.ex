defmodule Swoosh.Mailer do
  @moduledoc ~S"""
  Defines a mailer.

  A mailer is a wrapper around an adapter that makes it easy for you to swap the
  adapter without having to change your code.

  It is also responsible for doing some sanity checks before handing down the
  email to the adapter.

  When used, the mailer expects `:otp_app` as an option.
  The `:otp_app` should point to an OTP application that has the mailer
  configuration. For example, the mailer:

      defmodule Sample.Mailer do
        use Swoosh.Mailer, otp_app: :sample
      end

  Could be configured with:

      config :sample, Sample.Mailer,
        adapter: Swoosh.Adapters.Sendgrid,
        api_key: "SG.x.x"

  Most of the configuration that goes into the config is specific to the adapter,
  so check the adapter's documentation for more information.

  ## Examples

  Once configured you can use your mailer like this:

      # in an IEx console
      iex> email = %Swoosh.Email{} |> from("tony@stark.com") |> to("steve@rogers.com")
      %Swoosh.Email{from: {"", "tony@stark.com"}, ...}
      iex> Mailer.deliver(email)
      :ok
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {otp_app, adapter, config} = Swoosh.Mailer.parse_config(__MODULE__, opts)

      @adapter adapter
      @config config

      def __adapter__, do: @adapter

      def deliver(%Swoosh.Email{from: nil}), do: raise ArgumentError, "expected \"from\" to be set"
      def deliver(%Swoosh.Email{from: {_name, nil}}), do: raise ArgumentError, "expected \"from\" address to be set"
      def deliver(%Swoosh.Email{to: nil}), do: raise ArgumentError, "expected \"to\" to be set"
      def deliver(%Swoosh.Email{to: []}), do: raise ArgumentError, "expected \"to\" not to be empty"
      def deliver(%Swoosh.Email{subject: nil}), do: raise ArgumentError, "expected \"subject\" to be set"
      def deliver(%Swoosh.Email{html_body: nil, text_body: nil}) do
        raise ArgumentError, "expected \"html_body\" or \"text_body\" to be set"
      end
      def deliver(%Swoosh.Email{} = email), do: @adapter.deliver(email, @config)
      def deliver(email), do: raise ArgumentError, "expected %Swoosh.Email{}, got #{inspect email}"
    end
  end

  @doc """
  Parses the OTP configuration at compile time.
  """
  def parse_config(mailer, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config = Application.get_env(otp_app, mailer, [])
    adapter = opts[:adapter] || config[:adapter]

    unless adapter do
      raise ArgumentError, "missing :adapter configuration in " <>
                           "config #{inspect otp_app}, #{inspect mailer}"
    end

    {otp_app, adapter, config}
  end
end
