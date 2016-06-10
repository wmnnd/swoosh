defmodule Swoosh.Adapter do
  @moduledoc ~S"""
  Specification of the email delivery adapter.
  """

  @type t :: module

  @type email :: Email.t

  @typep config :: Keyword.t

  @doc """
  Validates the config passed to the adapter.
  """
  @callback validate_config(config) :: {:ok} | {:error, term}

  @doc """
  Delivers an email with the given config.
  """
  @callback deliver(email, config) :: {:ok, term} | {:error, term}
end
