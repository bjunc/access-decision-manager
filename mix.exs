defmodule AccessDecisionManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :access_decision_manager,
      name: "Access Decision Manager",
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "getting-started",
        extras: [
          "docs/getting-started.md"
        ]
      ]
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
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},

      # Optional dependencies
      {:plug, "~> 1.3.3 or ~> 1.4", optional: true}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
