defmodule Swoosh.InMemoryMailboxTest do
  use ExUnit.Case, async: true

  alias Swoosh.InMemoryMailbox

  test "start_link/0 starts with an empty mailbox" do
    {:ok, pid} = GenServer.start_link(InMemoryMailbox, [])
    count = GenServer.call(pid, :all) |> Enum.count
    assert count == 0
  end

  test "push an email into the mailbox" do
    InMemoryMailbox.push(%Swoosh.Email{})
    assert InMemoryMailbox.all() |> Enum.count() == 1
  end

  test "pop an email from the mailbox" do
    InMemoryMailbox.push(%Swoosh.Email{subject: "Test 1"})
    InMemoryMailbox.push(%Swoosh.Email{subject: "Test 2"})
    assert InMemoryMailbox.all() |> Enum.count() == 2

    email = InMemoryMailbox.pop()
    assert email.subject == "Test 2"
    assert InMemoryMailbox.all() |> Enum.count() == 1

    email = InMemoryMailbox.pop()
    assert email.subject == "Test 1"
    assert InMemoryMailbox.all() |> Enum.count() == 0
  end

  test "delete all the emails in the mailbox" do
    InMemoryMailbox.push(%Swoosh.Email{})
    InMemoryMailbox.push(%Swoosh.Email{})
    assert InMemoryMailbox.all() |> Enum.count() == 2

    InMemoryMailbox.delete_all()
    assert InMemoryMailbox.all() |> Enum.count() == 0
  end
end
