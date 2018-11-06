defmodule ExopProps.ParamsGenerator.Integer do
  @behaviour ExopProps.ParamsGenerator.Generator

  @diff 9999

  def generate(opts \\ []) do
    opts |> Keyword.get(:numericality) |> do_generate()
  end

  defp do_generate(%{equal_to: exact}) do
    StreamData.integer(exact..exact)
  end

  defp do_generate(%{greater_than: greater_than, less_than: less_than}) do
    StreamData.filter(
      StreamData.integer(greater_than..less_than),
      &(&1 > greater_than && &1 < less_than)
    )
  end

  defp do_generate(%{greater_than: greater_than, less_than_or_equal_to: less_than_or_equal_to}) do
    StreamData.filter(
      StreamData.integer(greater_than..less_than_or_equal_to),
      &(&1 > greater_than && &1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(%{greater_than_or_equal_to: greater_than_or_equal_to, less_than: less_than}) do
    StreamData.filter(
      StreamData.integer(greater_than_or_equal_to..less_than),
      &(&1 >= greater_than_or_equal_to && &1 < less_than)
    )
  end

  defp do_generate(%{
         greater_than_or_equal_to: greater_than_or_equal_to,
         less_than_or_equal_to: less_than_or_equal_to
       }) do
    StreamData.filter(
      StreamData.integer(greater_than_or_equal_to..less_than_or_equal_to),
      &(&1 >= greater_than_or_equal_to && &1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(%{greater_than: greater_than}) do
    StreamData.filter(
      StreamData.integer(greater_than..(greater_than + @diff)),
      &(&1 > greater_than)
    )
  end

  defp do_generate(%{greater_than_or_equal_to: greater_than_or_equal_to}) do
    StreamData.filter(
      StreamData.integer(greater_than_or_equal_to..(greater_than_or_equal_to + @diff)),
      &(&1 >= greater_than_or_equal_to)
    )
  end

  defp do_generate(%{less_than: less_than}) do
    StreamData.filter(StreamData.integer((less_than - @diff)..less_than), &(&1 < less_than))
  end

  defp do_generate(%{less_than_or_equal_to: less_than_or_equal_to}) do
    StreamData.filter(
      StreamData.integer((less_than_or_equal_to - @diff)..less_than_or_equal_to),
      &(&1 <= less_than_or_equal_to)
    )
  end

  defp do_generate(_), do: StreamData.integer()
end
