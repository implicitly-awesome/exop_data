defmodule ExopData.Generators.Struct do
  @moduledoc """
  Implements ExopData generators behaviour for `struct` parameter type.
  """

  @behaviour ExopData.Generator

  use ExUnitProperties

  alias ExopData.Generators

  def generate(opts \\ %{}, props_opts \\ %{}) do
    if struct_module = Map.get(opts, :struct_module) do
      new_inner =
        struct_module
        |> struct!(%{})
        |> Map.drop([:__struct__, :__meta__])
        |> Enum.reduce(Map.get(opts, :inner, %{}), fn
          {new_key, _}, original_inner -> Map.put_new(original_inner, new_key, type: :string)
        end)

      opts
      |> Map.put(:inner, new_inner)
      |> Generators.Map.generate(props_opts)
      |> StreamData.map(&struct!(struct_module, &1))
    else
      raise ArgumentError, """
      `type: :struct` check is not supported.
      You can provide custom generator for this parameter or one of checks:
      `struct: %MyStruct{}`, `struct: MyStruct` or `type: :map`
      """
    end
  end
end
