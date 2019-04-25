defmodule ExopData.Mixfile do
  use Mix.Project

  @description """
  The library provide the convenient way to generate data based on provided contract which describes
  data structure you're interesting in.
  """

  def project do
    [
      app: :exop_data,
      version: "0.1.7",
      elixir: ">= 1.6.0",
      name: "ExopData",
      description: @description,
      package: package(),
      deps: deps(),
      source_url: "https://github.com/madeinussr/exop_data",
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

  defp deps do
    [
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:stream_data, "~> 0.1"},
      {:randex, "~> 0.4"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Andrey Chernykh", "Aleksandr Fomin"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/madeinussr/exop_data"}
    ]
  end
end
