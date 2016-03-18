defmodule Swoosh.Adapters.Local do
  @behaviour Swoosh.Adapter

  def deliver(%Swoosh.Email{} = email, _config) do
    :ok = Swoosh.InMemoryMailbox.push(email)
  end
end
