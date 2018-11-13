defmodule ExopProps.CommonFilters do
  @moduledoc """
  Defines filters which are common for different types.
  """

  @doc """
  Applies common filters to a generator (the first argument) which may present
  in parameter options given as the second argument.
  """
  @spec filter(StreamData.t(), map()) :: StreamData.t()
  def filter(generator, param_opts) do
    generator
    |> allow_nil(param_opts)
    |> not_in(param_opts)
  end

  @doc """
  Applies `allow_nil` filter to a generator (the first argument) which may present
  in parameter options given as the second argument.
  """
  @spec allow_nil(StreamData.t(), map()) :: StreamData.t()
  def allow_nil(generator, param_opts) do
    do_allow_nil(generator, Map.get(param_opts, :allow_nil))
  end

  @doc """
  Applies `not_in` filter to a generator (the first argument) which may present
  in parameter options given as the second argument.
  """
  @spec not_in(StreamData.t(), map()) :: StreamData.t()
  def not_in(generator, param_opts) do
    do_not_in(generator, Map.get(param_opts, :not_in))
  end

  @spec do_allow_nil(StreamData.t(), map()) :: StreamData.t()
  defp do_allow_nil(generator, true) do
    StreamData.one_of([nil | List.duplicate(generator, 10)])
  end

  defp do_allow_nil(generator, _), do: generator

  @spec do_not_in(StreamData.t(), map()) :: StreamData.t()
  defp do_not_in(generator, list) when is_list(list) do
    StreamData.filter(generator, &(&1 not in list))
  end

  defp do_not_in(generator, _param_opts), do: generator
end
