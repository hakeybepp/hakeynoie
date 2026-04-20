defmodule Hakeynoie.MixProject do
  use Mix.Project

  def project do
    [
      app: :hakeynoie,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        hakeynoie: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  def application do
    [
      mod: {Hakeynoie.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Ash core
      {:ash, "~> 3.4"},
      {:ash_postgres, "~> 2.4"},
      {:ash_phoenix, "~> 2.3"},

      # Auth
      {:ash_authentication, "~> 4.4"},
      {:ash_authentication_phoenix, "~> 2.4"},

      # Phoenix
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.5"},

      # SAT solver for Ash policies
      {:simple_sat, "~> 0.1"},

      # HTTP
      {:corsica, "~> 2.1"},

      # Email
      {:swoosh, "~> 1.16"},
      {:gen_smtp, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end
