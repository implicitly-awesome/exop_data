defmodule ExopProps.ParamsGenerator.Struct do
  @moduledoc """
  Implements ExopProps generators behaviour for `struct` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  use ExUnitProperties

  alias ExopProps.ParamsGenerator.Term

  def generate(opts \\ []) do
    if struct_module = Keyword.get(opts, :struct_module) do
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
