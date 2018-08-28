defmodule Wanon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :wanon,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      test_paths: test_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Wanon.Application, []}
    ]
  end

  defp test_paths(:integration), do: ["integration"]
  defp test_paths(_), do: ["test"]

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13"},
      {:gen_stage, "~> 0.14"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.3"},
      {:excoveralls, "~> 0.10", only: [:test, :integration]},
      {:mox, "~> 0.4", only: :test},
      {:plug, "~> 1.6", only: :integration},
      {:cowboy, "~> 2.4", only: :integration},
      {:distillery, "~> 2.0", runtime: false}
    ]
  end

  defp aliases do
    # Drop, create and migrate databases before tests
    [
      test: ["ecto.drop", "ecto.create", "ecto.migrate", "test --no-start"]
    ]
  end
end
