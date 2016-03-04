defmodule Swoosh.Adapters.LocalTest do
  use ExUnit.Case, async: true

  defmodule TestMailer do
    use Swoosh.Mailer, otp_app: :swoosh, adapter: Swoosh.Adapters.Local
  end

  test "deliver/1" do
    email = %Swoosh.Email{
      to: "hello@email.com",
      subject: "Hello, world!",
    }
    TestMailer.deliver(email)

    assert Swoosh.InMemoryMailbox.pop() == email
  end
end
