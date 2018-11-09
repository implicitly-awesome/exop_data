defmodule ExopProps.ParamsGenerator.Map do
  @moduledoc """
  Implements ExopProps generators behaviour for `map` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(opts \\ %{}), do: opts |> Map.get(:length) |> do_generate()

  defp do_generate(%{is: exact}) do
    map(length: exact)
  end

  defp do_generate(%{in: min..max}) do
    map(min_length: min, max_length: max)
  end

  defp do_generate(%{min: min, max: max}) do
    map(min_length: min, max_length: max)
  end

  defp do_generate(%{min: min}) do
    map(min_length: min)
  end

  defp do_generate(%{max: max}) do
    map(max_length: max)
  end

  defp do_generate(_) do
    map()
  end

  defp map(opts \\ []) do
    [StreamData.binary(), StreamData.atom(:alphanumeric)]
    |> StreamData.one_of()
    |> StreamData.map_of(StreamData.binary(), opts)
  end
end
