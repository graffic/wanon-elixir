defmodule Wanon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :wanon,
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      test_paths: test_paths(Mix.env)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :postgrex, :httpoison],
      mod: {Wanon.Application, []}
    ]
  end

  defp test_paths(:integration), do: ["integration"]
  defp test_paths(_), do: ["test"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13"},
      {:gen_stage, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:excoveralls, "~> 0.8", only: :test},
      {:plug, "~> 1.5", only: :integration},
      {:cowboy, "~> 2.3", only: :integration}
    ]
  end

  defp aliases do
    # Drop, create and migrate databases before tests
    [
      "test": ["ecto.drop", "ecto.create", "ecto.migrate", "test --no-start"]
    ]
  end
end
