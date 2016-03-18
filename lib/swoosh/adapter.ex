defmodule Swoosh.Adapter do
  @typep config :: Keyword.t

  @callback deliver(%Swoosh.Email{}, config) :: :ok | {:ok, term} | {:error, term}
end
