defmodule ExopProps.ParamsGenerator.List do
  @moduledoc """
  Implements ExopProps generators behaviour for `list` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  import ExopProps.InnerResolver

  alias ExopProps.ParamsGenerator

  def generate(opts \\ %{})

  def generate(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> generate()

  def generate(%{inner: _} = opts) do
    opts |> Map.put(:inner, resolve_inner_opts(opts)) |> do_generate()
  end

  def generate(opts), do: do_generate(opts)

  @spec do_generate(map()) :: StreamData.t()
  defp do_generate(%{inner: _} = opts), do: StreamData.map(generator(opts), &Enum.into(&1, []))

  defp do_generate(opts), do: StreamData.list_of(list_item(opts), length_opts(opts))

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

  @spec list_item(map()) :: StreamData.t()
  defp list_item(opts) do
    opts = opts |> Map.get(:list_item, %{}) |> Enum.into(%{})

    if Enum.any?(opts) do
      ParamsGenerator.resolve_opts(opts)
    else
      StreamData.atom(:alphanumeric)
    end
  end
end
