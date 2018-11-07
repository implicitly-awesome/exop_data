defmodule ExopProps.ParamsGenerator.CommonFilters do
  @moduledoc """
  Defines filters which are common for different types.
  """

  # TODO: required & default options

  def filter(generator, opts), do: not_in(generator, opts)

  def not_in(generator, opts), do: do_not_in(generator, Keyword.get(opts, :not_in))

  defp do_not_in(generator, list) when is_list(list) do
    StreamData.filter(generator, &(&1 not in list))
  end

  defp do_not_in(generator, _), do: generator
end
