defmodule ExopProps.ParamsGenerator.Map do
  @moduledoc """
  Implements ExopProps generators behaviour for `map` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  import ExopProps.InnerResolver

  def generate(opts \\ %{})

  def generate(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> generate()

  def generate(%{inner: _} = opts) do
    opts |> Map.put(:inner, resolve_inner_opts(opts)) |> do_generate()
  end

  def generate(opts), do: do_generate(opts)

  @spec do_generate(map()) :: StreamData.t()
  defp do_generate(%{inner: _} = opts), do: generator(opts)

  defp do_generate(opts) do
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
