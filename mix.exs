defmodule Swoosh.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :swoosh,
     version: @version,
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,

     # Hex
     description: description,
     package: package,

     # Docs
     name: "Swoosh",
     docs: [source_ref: "v#{@version}", main: "Swoosh",
            canonical: "http://hexdocs.pm/swoosh",
            source_url: "https://github.com/swoosh/swoosh"]]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Swoosh.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison, "~> 2.1"},
     {:gen_smtp, "~> 0.9.0"},
     {:cowboy, "~> 1.0.0", optional: true},
     {:plug, "~> 1.1", optional: true},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:bypass, "~> 0.5", only: [:test]},
     {:ex_doc, "~> 0.10", only: :docs},
     {:earmark, "~> 0.1", only: :docs},
     {:inch_ex, ">= 0.0.0", only: :docs}]
  end

  defp description do
    """
    Compose, deliver and test your emails easily in Elixir. Supports SMTP, Sendgrid, Mandrill, Postmark and Mailgun out of the box.
    Works great with Phoenix.
    """
  end

  defp package do
    [maintainers: ["Steve Domin", "Baris Balic"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/swoosh/swoosh"}]
  end
end
