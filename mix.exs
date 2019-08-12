defmodule Acmex.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/sergioaugrod/acmex"

  def project do
    [
      app: :acmex,
      deps: deps(),
      elixir: "~> 1.9",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      version: @version,

      # Hex
      description: "Acmex is an Elixir Client for the Lets Encrypt ACMEv2 protocol.",
      package: package(),

      # Docs
      name: "Acmex",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.11", only: :test},
      {:httpoison, "~> 1.5"},
      {:jose, "~> 1.9"},
      {:jason, "~> 1.1"}
    ]
  end

  defp package do
    [
      maintainers: ["Sérgio Rodrigues"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp docs do
    [
      main: "Acmex",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
