defmodule Swoosh.Adapter do
  @moduledoc ~S"""
  Specification of the email delivery adapter.
  """
  @typep config :: Keyword.t

  @callback deliver(%Swoosh.Email{}, config) :: :ok | {:ok, term} | {:error, term}
end
