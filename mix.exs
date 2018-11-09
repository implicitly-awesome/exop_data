defmodule ExopProps.Mixfile do
  use Mix.Project

  @description """
  Here will be a description
  """

  def project do
    [
      app: :exop_props,
      version: "0.0.0",
      elixir: "~> 1.5",
      name: "ExopProps",
      description: @description,
      package: package(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/madeinussr/exop_props",
      docs: [extras: ["README.md"]],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      applications: [:logger, :stream_data]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ex_doc, "~> 0.12", only: [:dev, :test, :docs]},
      {:stream_data, "~> 0.1"},
      {:exop, "~> 1.1.4"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Andrey Chernykh", "Aleksandr Fomin"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/madeinussr/exop_props"}
    ]
  end
end
