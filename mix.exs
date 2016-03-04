defmodule Swoosh.Mixfile do
  use Mix.Project

  def project do
    [app: :swoosh,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
  end

  def application do
    [applications: [:logger],
     mod: {Swoosh.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:httpoison, "~> 0.8"}]
  end

  defp description do
    """
    """
  end

  defp package do
    [maintainers: [],
     licenses: ["MIT"],
     links: %{"GitHub" => ""}]
  end

end
