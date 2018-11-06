defmodule ExopProps.MixProject do
  use Mix.Project

  def project do
    [
      app: :exop_props,
      version: "0.0.0",
      elixir: "~> 1.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:stream_data, "~> 0.1"}
    ]
  end
end
