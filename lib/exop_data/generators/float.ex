defmodule ExopData.Generators.Float do
  @moduledoc """
  Implements ExopData generators behaviour for `float` parameter type.
  """

  @behaviour ExopData.Generator

  @diff 0.1

  def generate(opts \\ %{}, _props_opts \\ %{}) do
    opts |> Map.get(:numericality) |> do_generate()
  end

  @spec do_generate(map()) :: StreamData.t()
  defp do_generate(%{equal_to: exact}), do: constant(exact)

  defp do_generate(%{equals: exact}), do: constant(exact)

  defp do_generate(%{is: exact}), do: constant(exact)

  defp do_generate(%{min: min} = contract) do
    contract
    |> Map.delete(:min)
    |> Map.put(:greater_than_or_equal_to, min)
    |> do_generate()
  end

  defp do_generate(%{max: max} = contract) do
    contract
    |> Map.delete(:max)
    |> Map.put(:less_than_or_equal_to, max)
    |> do_generate()
  end

  defp do_generate(%{greater_than: greater_than, less_than: less_than}) do
    StreamData.filter(
      StreamData.float(min: greater_than - @diff, max: less_than + @diff),
      &(&1 > greater_than && &1 < less_than)
    )
  end

  defp do_generate(%{greater_than: greater_than, less_than_or_equal_to: less_than_or_equal_to}) do
    StreamData.filter(
      StreamData.float(min: greater_than - @diff, max: less_than_or_equal_to),
      &(&1 > greater_than && &1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(%{greater_than_or_equal_to: greater_than_or_equal_to, less_than: less_than}) do
    StreamData.filter(
      StreamData.float(min: greater_than_or_equal_to, max: less_than + @diff),
      &(&1 >= greater_than_or_equal_to && &1 < less_than)
    )
  end

  defp do_generate(%{
         greater_than_or_equal_to: greater_than_or_equal_to,
         less_than_or_equal_to: less_than_or_equal_to
       }) do
    StreamData.filter(
      StreamData.float(min: greater_than_or_equal_to, max: less_than_or_equal_to),
      &(&1 >= greater_than_or_equal_to && &1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(%{greater_than: greater_than}) do
    StreamData.filter(StreamData.float(min: greater_than - @diff), &(&1 > greater_than))
  end

  defp do_generate(%{greater_than_or_equal_to: greater_than_or_equal_to}) do
    StreamData.filter(
      StreamData.float(min: greater_than_or_equal_to),
      &(&1 >= greater_than_or_equal_to)
    )
  end

  defp do_generate(%{less_than: less_than}) do
    StreamData.filter(StreamData.float(max: less_than + @diff), &(&1 < less_than))
  end

  defp do_generate(%{less_than_or_equal_to: less_than_or_equal_to}) do
    StreamData.filter(
      StreamData.float(max: less_than_or_equal_to),
      &(&1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(_), do: StreamData.float()

  @spec constant(float()) :: StreamData.t()
  defp constant(value), do: StreamData.constant(value)
end
