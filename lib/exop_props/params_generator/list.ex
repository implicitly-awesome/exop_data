defmodule ExopProps.ParamsGenerator.List do
  @behaviour ExopProps.ParamsGenerator.Generator

  alias ExopProps.ParamsGenerator
  require ExopProps.ParamsGenerator

  use ExopProps

  def generate(opts \\ []) do
    StreamData.list_of(list_item(opts), length_opts(opts))
  end

  defp length_opts(opts) do
    case Keyword.get(opts, :length) do
      %{is: exact} -> [length: exact]
      %{in: min..max} -> [min_length: min, max_length: max]
      %{min: min, max: max} -> [min_length: min, max_length: max]
      %{min: min} -> [min_length: min]
      %{max: max} -> [max_length: max]
      _ -> []
    end
  end

  defp list_item(opts) do
    opts = opts |> Keyword.get(:list_item, []) |> Enum.into([])

    if Enum.any?(opts), do: ParamsGenerator.generator(opts), else: StreamData.atom(:alphanumeric)
  end
end
