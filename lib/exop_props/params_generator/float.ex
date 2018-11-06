defmodule ExopProps.ParamsGenerator.Float do
  @behaviour ExopProps.ParamsGenerator.Generator

  @diff 0.1

  def generate(opts \\ []), do: opts |> Keyword.get(:numericality) |> do_generate()

  defp do_generate(%{equal_to: exact}) do
    StreamData.float(min: exact, max: exact)
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
end
