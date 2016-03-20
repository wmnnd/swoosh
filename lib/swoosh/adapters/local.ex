defmodule Swoosh.Adapters.Local do
  @behaviour Swoosh.Adapter

  def deliver(%Swoosh.Email{} = email, _config) do
    Swoosh.InMemoryMailbox.push(email)
  end
end
