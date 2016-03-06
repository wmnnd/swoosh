defmodule Swoosh.Mailer do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {otp_app, adapter, config} = Swoosh.Mailer.parse_config(__MODULE__, opts)

      @adapter adapter
      @config config

      def __adapter__, do: @adapter

      def deliver(%Swoosh.Email{from: nil}) do
        raise ArgumentError, "expected \"from\" to be set"
      end
      def deliver(%Swoosh.Email{to: nil}) do
        raise ArgumentError, "expected \"to\" to be set"
      end
      def deliver(%Swoosh.Email{html_body: nil, text_body: nil}) do
        raise ArgumentError, "expected \"html_body\" or \"text_body\" to be set"
      end
      def deliver(%Swoosh.Email{} = email) do
        @adapter.deliver(email)
      end
      def deliver(email) do
        raise ArgumentError, "expected %Swoosh.Email{}, got #{inspect email}"
      end
    end
  end

  @doc """
  Parses the OTP configuration for compile time.
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
