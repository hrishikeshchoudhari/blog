defmodule Blog.MixProject do
  use Mix.Project

  def project do
    [
      app: :blog,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Blog.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.3"},
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.12"},
      {:postgrex, "~> 0.20.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      # {:floki, ">= 0.30.0", only: :test},
      {:floki, "~> 0.37.1"},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.19"},
      {:finch, "~> 0.19"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.2"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.7"},
      {:live_monaco_editor, "0.1.8"},
      {:md, "~> 0.10.7"},
      {:timex, "~> 3.7"},
      {:plug, "~> 1.17", override: true},
      {:tidewave, "~> 0.1", only: :dev},
      {:xml_builder, "~> 2.2"},
      {:atomex, "~> 0.5.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
