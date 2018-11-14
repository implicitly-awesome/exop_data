defmodule ExopProps.InnerResolver do
  @moduledoc """
  Contains functions to resolve and generate a parameter's :inner check (options)
  """

  @inner_params_amount_delta 5

  alias ExopProps.ParamsGenerator

  defguard has_inner(value) when is_map(value) or (is_list(value) and length(value) > 0)

  @doc """
  Resolve :inner opts according to it's original checks.
  Returns updated (if needed) :inner check's opts.
  """
  @spec resolve_inner_opts(%{length: map(), inner: map()}) :: map()
  def resolve_inner_opts(%{length: length_opts, inner: inner_opts})
      when is_map(length_opts) and is_map(inner_opts) do
    amount_to_add = inner_params_amount_to_add(length_opts, Enum.count(inner_opts))

    if amount_to_add > 0 do
      StreamData.atom(:alphanumeric)
      |> StreamData.map_of(StreamData.constant(required: true), length: 1)
      |> Enum.take(amount_to_add)
      |> Enum.reduce(inner_opts, fn x, acc -> Map.merge(acc, x, fn _k, v1, _v2 -> v1 end) end)
    else
      inner_opts
    end
  end

  def resolve_inner_opts(%{inner: inner_opts}) when is_map(inner_opts), do: inner_opts

  def resolve_inner_opts(_), do: %{}

  @spec inner_params_amount_to_add(map(), integer()) :: integer()
  defp inner_params_amount_to_add(%{in: _min_length..max_length}, inner_params_amount) do
    inner_params_amount_to_add(%{max: max_length}, inner_params_amount)
  end

  defp inner_params_amount_to_add(%{min: _min_length, max: max_length}, inner_params_amount) do
    inner_params_amount_to_add(%{max: max_length}, inner_params_amount)
  end

  defp inner_params_amount_to_add(%{max: max_length}, inner_params_amount) do
    Enum.random(1..(max_length - inner_params_amount))
  end

  defp inner_params_amount_to_add(%{min: min_length}, _inner_params_amount) do
    Enum.random(min_length..(min_length + @inner_params_amount_delta))
  end

  @doc """
  Prepare StreamData generator depends on a parameter :inner check opts and opts given to ExopProps generator.
  """
  @spec generator(map(), map()) :: StreamData.t()
  def generator(%{inner: inner_opts}, props_opts) when has_inner(inner_opts) do
    inner_contract =
      inner_opts
      |> Enum.into(%{})
      |> Enum.map(fn {param_name, param_opts} -> %{name: param_name, opts: param_opts} end)

    props_opts = resolve_custom_generators(props_opts)

    ParamsGenerator.generate_for(inner_contract, props_opts)
  end

  @spec resolve_custom_generators(map()) :: map()
  defp resolve_custom_generators(%{generators: generators} = props_opts) do
    custom_generators_next_level =
      generators
      |> Map.values()
      |> Enum.filter(&is_map(&1))
      |> Enum.reduce(%{}, fn m, acc -> Map.merge(acc, m) end)

    Map.put(props_opts, :generators, custom_generators_next_level)
  end

  defp resolve_custom_generators(props_opts), do: props_opts
end
