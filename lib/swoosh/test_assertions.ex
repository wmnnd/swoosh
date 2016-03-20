defmodule Swoosh.TestAssertions do
  @moduledoc ~S"""
  This module contains a set of assertions functions that you can import in your
  test cases.

  It is meant to be used with the
  [Swoosh.Adapters.Test](Swoosh.Adapters.Test.html) module.
  """

  import ExUnit.Assertions

  @doc ~S"""
  Asserts `email` was sent.
  """
  def assert_email_sent(email) do
    assert_received {:email, ^email}
  end

  @doc ~S"""
  Asserts `email` was not sent.
  """
  def assert_email_not_sent(email) do
    refute_received {:email, ^email}
  end

  @doc ~S"""
  Asserts no emails were sent.
  """
  def assert_no_email_sent() do
    refute_received {:email, _}
  end
end
