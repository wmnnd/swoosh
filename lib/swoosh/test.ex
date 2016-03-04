defmodule Swoosh.Test do
  @moduledoc """
  """

  import ExUnit.Assertions

  def assert_email_sent(%Swoosh.Email{} = email) do
    assert_received {:email, ^email}
  end

  def assert_email_not_sent(email) do
    refute_received {:email, ^email}
  end

  def assert_no_email_sent() do
    refute_received {:email, _}
  end
end
