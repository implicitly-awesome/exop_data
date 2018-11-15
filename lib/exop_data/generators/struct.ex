defmodule ExopData.Generators.Struct do
  @moduledoc """
  Implements ExopData generators behaviour for `struct` parameter type.
  """

  @behaviour ExopData.Generator

  use ExUnitProperties

  alias ExopData.Generators

  def generate(opts \\ %{}, props_opts \\ %{}) do
    if struct_module = Map.get(opts, :struct_module) do
      keys = struct_module |> struct!(%{}) |> Map.keys() |> List.delete(:__struct__)

      original_inner = Map.get(opts, :inner, %{})

      new_inner = Enum.reduce(keys, %{}, &Map.put(&2, &1, type: :atom))

      opts
      |> Map.put(:inner, Map.merge(new_inner, original_inner))
      |> Generators.Map.generate(props_opts)
      |> StreamData.map(&struct!(struct_module, &1))
    else
      raise ArgumentError, """
      `type: :struct` check is not supported.
      You can provide custom generator for this parameter,
      `struct: %MyStruct{}` or `type: :map`
      """
    end
  end
end
