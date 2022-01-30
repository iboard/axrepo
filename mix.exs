defmodule Axrepo.MixProject do
  use Mix.Project

  defp description() do
    ~s"""
    A simple Repository for 'Altex'. Implements an 'ETS' and a 'dETS'
    gateway.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Andreas Altendorfer"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/iboard/axrepo"}
    ]
  end

  def project do
    [
      app: :axrepo,
      version: "0.1.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      xref: [exclude: [:crypto]],

      # Hex
      package: package(),
      description: description(),
      licenses: ["MIT"],
      links: ["https://github.com/iboard/altex"],

      # Docs
      name: "Altex.Repo",
      source_url: "https://github.com/iboard/axrepo",
      homepage_url: "https://github.com/iboard/altex",
      docs: [
        # The main page in the docs
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Altex.Repo.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:axentity, "~> 0.1"},
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end
end
