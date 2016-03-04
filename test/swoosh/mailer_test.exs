defmodule Swoosh.MailerTest do
  use ExUnit.Case, async: true

  test "should raise if no adapter is specified" do
    assert_raise ArgumentError, fn ->
      defmodule NoAdapterMailer do
        use Swoosh.Mailer, otp_app: :swoosh
      end
    end
  end
end
