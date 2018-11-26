defmodule ExopData.Generators.Map do
  @moduledoc """
  Implements ExopData generators behaviour for `map` parameter type.
  """

  @behaviour ExopData.Generator

  import ExopData.InnerResolver

  def generate(opts \\ %{}, props_opts \\ %{})

  def generate(opts, props_opts) when is_list(opts) do
    opts |> Enum.into(%{}) |> generate(props_opts)
  end

  def generate(opts, props_opts) when is_list(props_opts) do
    generate(opts, Enum.into(props_opts, %{}))
  end

  def generate(%{inner: _} = opts, props_opts) do
    opts |> Map.put(:inner, resolve_inner_opts(opts)) |> do_generate(props_opts)
  end

  def generate(opts, props_opts), do: do_generate(opts, props_opts)

  @spec do_generate(map(), map()) :: StreamData.t()
  defp do_generate(%{inner: _} = opts, props_opts), do: generator(opts, props_opts)

  defp do_generate(opts, _props_opts) do
    [StreamData.binary(), StreamData.atom(:alphanumeric)]
    |> StreamData.one_of()
    |> StreamData.map_of(StreamData.binary(), length_opts(opts))
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
end
