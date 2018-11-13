defmodule ExopProps.ParamsGenerator.List do
  @moduledoc """
  Implements ExopProps generators behaviour for `list` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  import ExopProps.InnerResolver

  alias ExopProps.ParamsGenerator

  def generate(opts \\ %{}, props_opts \\ %{})

  def generate(opts, props_opts) when is_list(opts),
    do: opts |> Enum.into(%{}) |> generate(props_opts)

  def generate(opts, props_opts) when is_list(props_opts),
    do: generate(opts, Enum.into(props_opts, %{}))

  def generate(%{inner: _} = opts, props_opts) do
    opts |> Map.put(:inner, resolve_inner_opts(opts)) |> do_generate(props_opts)
  end

  def generate(opts, props_opts), do: do_generate(opts, props_opts)

  @spec do_generate(map(), map()) :: StreamData.t()
  defp do_generate(%{inner: _} = opts, props_opts),
    do: StreamData.map(generator(opts, props_opts), &Enum.into(&1, []))

  defp do_generate(opts, props_opts),
    do: StreamData.list_of(list_item(opts, props_opts), length_opts(opts))

  @spec length_opts(map()) :: StreamData.t()
  defp length_opts(opts) do
    case Map.get(opts, :length) do
      %{is: exact} -> [length: exact]
      %{equals: exact} -> [length: exact]
      %{equal_to: exact} -> [length: exact]
      %{in: min..max} -> [min_length: min, max_length: max]
      %{min: min, max: max} -> [min_length: min, max_length: max]
      %{min: min} -> [min_length: min]
      %{max: max} -> [max_length: max]
      _ -> []
    end
  end

  @spec list_item(map(), map()) :: StreamData.t()
  defp list_item(opts, props_opts) do
    opts = opts |> Map.get(:list_item, %{}) |> Enum.into(%{})

    if Enum.any?(opts) do
      ParamsGenerator.generator_for_opts(opts, props_opts)
    else
      StreamData.atom(:alphanumeric)
    end
  end
end
