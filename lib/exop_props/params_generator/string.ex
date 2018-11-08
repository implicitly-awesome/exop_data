defmodule ExopProps.ParamsGenerator.String do
  @moduledoc """
  Implements ExopProps generators behaviour for `string` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(opts \\ %{}) do
    opts |> Map.get(:length) |> do_generate()
  end

  defp do_generate(%{is: exact}), do: StreamData.string(:ascii, length: exact)

  defp do_generate(%{in: min..max}),
    do: StreamData.string(:ascii, min_length: min, max_length: max)

  defp do_generate(%{min: min, max: max}),
    do: StreamData.string(:ascii, min_length: min, max_length: max)

  defp do_generate(%{min: min}), do: StreamData.string(:ascii, min_length: min)

  defp do_generate(%{max: max}), do: StreamData.string(:ascii, max_length: max)

  defp do_generate(_), do: StreamData.string(:ascii)
end
