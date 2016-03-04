defmodule Swoosh.Adapter do
  @callback deliver(%Swoosh.Email{}) :: any
end
