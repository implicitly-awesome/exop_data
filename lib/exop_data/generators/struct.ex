defmodule ExopData.Generators.Struct do
  @moduledoc """
  Implements ExopData generators behaviour for `struct` parameter type.
  """

  @behaviour ExopData.Generator

  use ExUnitProperties

  alias ExopData.Generators.Term

  def generate(opts \\ %{}, _props_opts \\ %{}) do
    if struct_module = Map.get(opts, :struct_module) do
      struct = struct!(struct_module, %{})
      keys = struct |> Map.keys() |> List.delete(:__struct__)

      gen all atom <- Term.generate([]) do
        Enum.reduce(keys, struct, fn key, struct ->
          Map.put(struct, key, atom)
        end)
      end
    else
      raise("You need to provide :struct_module option: `struct_module: Test`")
    end
  end
end