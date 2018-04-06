defmodule Wanon.Mixfile do
  use Mix.Project

  def project do
    [
      app: :wanon,
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :postgrex, :httpoison],
      mod: {Wanon.Application, []}
    ]
  end

  # WIP: To change or not to change main app while testing
  defp mod(:test), do: {Wanon.TestApplication}

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13"},
      {:gen_stage, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"}
    ]
  end

  defp aliases do
    # Drop, create and migrate databases before tests
    [
      "test": ["ecto.drop", "ecto.create", "ecto.migrate", "test"]
    ]
  end
end
