defmodule Swoosh.Adapters.LocalTest do
  use ExUnit.Case, async: true

  defmodule LocalMailer do
    use Swoosh.Mailer, otp_app: :swoosh, adapter: Swoosh.Adapters.Local
  end

  test "deliver/1" do
    email = %Swoosh.Email{
      from: "tony@stark.com",
      to: "steve@rogers.com",
      subject: "Hello, Avengers!",
      text_body: "Hello!"
    }
    LocalMailer.deliver(email)

    assert Swoosh.InMemoryMailbox.pop() == email
  end
end
