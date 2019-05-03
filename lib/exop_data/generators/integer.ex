defmodule ExopData.Generators.Integer do
  @moduledoc """
  Implements ExopData generators behaviour for `integer` parameter type.
  """

  alias ExopData.Generators.AliasResolvers.Numericality

  @behaviour ExopData.Generator

  @diff 9999

  def generate(opts \\ %{}, _props_opts \\ %{}) do
    opts |> Map.get(:numericality) |> Numericality.resolve_aliases() |> do_generate()
  end

  @spec do_generate(map()) :: StreamData.t()
  @spec do_generate(map()) :: StreamData.t()
  defp do_generate(%{equal_to: exact}), do: constant(exact)

  defp do_generate(%{equals: exact}), do: constant(exact)

  defp do_generate(%{is: exact}), do: constant(exact)

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

  @spec constant(integer()) :: StreamData.t()
  defp constant(value), do: StreamData.constant(value)

  @spec in_range(integer(), integer()) :: StreamData.t()
  defp in_range(min, max), do: StreamData.integer(min..max)
end
