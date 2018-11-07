defmodule ExopProps.ParamsGenerator.List do
  @moduledoc """
  Implements ExopProps generators behaviour for `list` parameter type.
  """

  use ExopProps

  alias ExopProps.ParamsGenerator

  @behaviour ExopProps.ParamsGenerator.Generator

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

    if Enum.any?(opts),
      do: ParamsGenerator.resolve_opts(opts),
      else: StreamData.atom(:alphanumeric)
  end
end
