defmodule Swoosh.Adapters.Test do
  @moduledoc """
  """

  @behaviour Swoosh.Adapter

  def deliver(email) do
    send(self(), {:email, email})
  end
end
