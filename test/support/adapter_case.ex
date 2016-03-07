defmodule AdapterCase do
  @moduledoc "Conveniences for testing adapters."

  use ExUnit.CaseTemplate

  using do
    quote do
      defp parse(conn, opts \\ []) do
        opts = Keyword.put_new(opts, :parsers, [Plug.Parsers.URLENCODED])
        Plug.Parsers.call(conn, Plug.Parsers.init(opts))
      end
    end
  end
end
