defmodule ExopProps.ParamsGenerator.Map do
  @moduledoc """
  Implements ExopProps generators behaviour for `map` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  @inner_params_amount_delta 5

  alias ExopProps.ParamsGenerator

  defguard has_inner(value) when is_map(value) or (is_list(value) and length(value) > 0)

  def generate(opts \\ %{})

  def generate(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> generate()

  def generate(%{inner: _} = opts) do
    opts |> Map.put(:inner, resolve_inner_opts(opts)) |> do_generate()
  end

  def generate(opts), do: do_generate(opts)

  @spec do_generate(map()) :: StreamData.t()
  defp do_generate(%{inner: _} = opts), do: inner(opts)

  defp do_generate(opts) do
    [StreamData.binary(), StreamData.atom(:alphanumeric)]
    |> StreamData.one_of()
    |> StreamData.map_of(StreamData.binary(), length_opts(opts))
  end

  @spec inner(map()) :: StreamData.t()
  defp inner(%{inner: inner_opts}) when has_inner(inner_opts) do
    inner_opts
    |> Enum.into(%{})
    |> contract_for_opts()
    |> ParamsGenerator.generate_for([])

    # StreamData.map(generator, fn(map) -> Enum.into(map, []) end)
  end

  @spec length_opts(map()) :: StreamData.t()
  defp length_opts(%{length: length_check}) do
    case length_check do
      %{is: exact} -> [length: exact]
      %{equals: exact} -> [length: exact]
      %{equal_to: exact} -> [length: exact]
      %{min: min, max: max} -> [min_length: min, max_length: max]
      %{min: min} -> [min_length: min]
      %{max: max} -> [max_length: max]
      %{in: min..max} -> [min_length: min, max_length: max]
      _ -> []
    end
  end

  defp length_opts(_), do: []

  @spec contract_for_opts(map()) :: [%{name: atom(), opts: map() | keyword()}]
  defp contract_for_opts(opts) do
    Enum.map(opts, fn {param_name, param_opts} ->
      %{name: param_name, opts: param_opts}
    end)
  end

  @spec resolve_inner_opts(%{length: map(), inner: map()}) :: map()
  defp resolve_inner_opts(%{length: length_opts, inner: inner_opts})
       when is_map(length_opts) and is_map(inner_opts) do
    amount_to_add = inner_params_amount_to_add(length_opts, Enum.count(inner_opts))

    if amount_to_add > 0 do
      StreamData.atom(:alphanumeric)
      |> StreamData.map_of(StreamData.constant(required: true), length: 1)
      |> Enum.take(amount_to_add)
      |> Enum.reduce(inner_opts, fn x, acc -> Map.merge(acc, x) end)
    else
      inner_opts
    end
  end

  defp resolve_inner_opts(%{inner: inner_opts}) when is_map(inner_opts), do: inner_opts

  defp resolve_inner_opts(_), do: %{}

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
end
