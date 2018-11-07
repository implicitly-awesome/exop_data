defmodule ExopProps.ParamsGenerator.Integer do
  @moduledoc """
  Implements ExopProps generators behaviour for `integer` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  @diff 9999

  def generate(opts \\ []) do
    opts |> Keyword.get(:numericality) |> do_generate()
  end

  defp do_generate(%{equal_to: exact}) do
    StreamData.constant(exact)
  end

  defp do_generate(%{greater_than: min, less_than: max}) do
    in_range(min + 1, max - 1)
  end

  defp do_generate(%{greater_than: min, less_than_or_equal_to: max}) do
    in_range(min + 1, max)
  end

  defp do_generate(%{greater_than_or_equal_to: min, less_than: max}) do
    in_range(min, max - 1)
  end

  defp do_generate(%{greater_than_or_equal_to: min, less_than_or_equal_to: max}) do
    in_range(min, max)
  end

  defp do_generate(%{greater_than: min}) do
    in_range(min + 1, min + @diff)
  end

  defp do_generate(%{greater_than_or_equal_to: min}) do
    in_range(min, min + @diff)
  end

  defp do_generate(%{less_than: max}) do
    in_range(max - @diff, max - 1)
  end

  defp do_generate(%{less_than_or_equal_to: max}) do
    in_range(max - @diff, max)
  end

  defp do_generate(_), do: StreamData.integer()

  defp in_range(min, max), do: StreamData.integer(min..max)
end
