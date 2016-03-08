defmodule Swoosh.Mixfile do
  use Mix.Project

  def project do
    [app: :swoosh,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: compilers(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Swoosh.Application, []}]
  end

  defp compilers(:test), do: [:phoenix] ++ Mix.compilers
  defp compilers(_), do: Mix.compilers

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison, "~> 2.1"},
     {:phoenix, "~> 1.1", only: [:test]},
     {:phoenix_html, "~> 2.2", only: [:test]},
     {:bypass, "~> 0.5", only: [:test]}]
  end

  defp description do
    """
    Make Email great again.
    """
  end

  defp package do
    [maintainers: [],
     licenses: ["MIT"],
     links: %{"GitHub" => ""}]
  end

end
