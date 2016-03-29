defmodule Swoosh.MailerTest do
  use ExUnit.Case, async: true

  alias Swoosh.Mailer

  defmodule FakeMailer do
    use Swoosh.Mailer, otp_app: :swoosh, adapter: Swoosh.TestAdapter
  end

  test "should raise if no adapter is specified" do
    assert_raise ArgumentError, fn ->
      defmodule NoAdapterMailer do
        use Swoosh.Mailer, otp_app: :swoosh
      end
    end
  end

  test "should raise if deliver/1 is not called with %Swoosh.Email{}" do
    assert_raise ArgumentError, "expected %Swoosh.Email{}, got nil", fn ->
      FakeMailer.deliver(nil)
    end
  end

  test "should raise if deliver/1 is called with invalid email" do
    valid_email = %Swoosh.Email{from: "tony@stark.com",
                                to: "steve@rogers.com",
                                subject: "Test Email",
                                html_body: "<h1>Hello</h1>",
                                text_body: "Hello"}

    assert_raise ArgumentError, "expected \"from\" to be set", fn ->
      Map.put(valid_email, :from, nil) |> FakeMailer.deliver()
    end
    assert_raise ArgumentError, "expected \"from\" address to be set", fn ->
      Map.put(valid_email, :from, {"Name", nil}) |> FakeMailer.deliver()
    end

    assert_raise ArgumentError, "expected \"to\" to be set", fn ->
      Map.put(valid_email, :to, nil) |> FakeMailer.deliver()
    end
    assert_raise ArgumentError, "expected \"to\" not to be empty", fn ->
      Map.put(valid_email, :to, []) |> FakeMailer.deliver()
    end

    assert_raise ArgumentError, "expected \"subject\" to be set", fn ->
      Map.put(valid_email, :subject, nil) |> FakeMailer.deliver()
    end

    assert_raise ArgumentError, "expected \"html_body\" or \"text_body\" to be set", fn ->
      valid_email
      |> Map.put(:html_body, nil)
      |> Map.put(:text_body, nil)
      |> FakeMailer.deliver()
    end
  end

  test "config from environment variables" do
    System.put_env("SMTP_USERNAME", "userenv")
    System.put_env("SMTP_PASSWORD", "passwordenv")

    config = [username: {:system, "SMTP_USERNAME"},
              password: {:system, "SMTP_PASSWORD"},
              relay: "smtp.sendgrid.net",
              tls: :always]

    assert Mailer.parse_runtime_config(config) ==
      [username: "userenv",
       password: "passwordenv",
       relay: "smtp.sendgrid.net",
       tls: :always]
  end
end
