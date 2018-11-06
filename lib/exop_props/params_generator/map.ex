defmodule ExopProps.ParamsGenerator.Map do
  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(opts \\ []), do: opts |> Keyword.get(:length) |> do_generate()

  defp do_generate(%{is: exact}) do
    StreamData.map_of(StreamData.term(), StreamData.term(), length: exact)
  end

  defp do_generate(%{in: min..max}) do
    StreamData.map_of(StreamData.term(), StreamData.term(), min_length: min, max_length: max)
  end

  defp do_generate(%{min: min, max: max}) do
    StreamData.map_of(StreamData.term(), StreamData.term(), min_length: min, max_length: max)
  end

  defp do_generate(%{min: min}) do
    StreamData.map_of(StreamData.term(), StreamData.term(), min_length: min)
  end

  defp do_generate(%{max: max}) do
    StreamData.map_of(StreamData.term(), StreamData.term(), max_length: max)
  end

  defp do_generate(_) do
    StreamData.map_of(StreamData.term(), StreamData.term())
  end
end
