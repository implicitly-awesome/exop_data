defmodule ExopData.Generators.ModuleTest do
  use ExUnit.Case, async: true
  import ExUnitProperties

  import ExopData.Generators.Module, only: [generate: 1]

  property "generates 'alias' atoms" do
    generator = generate(%{})

    check all value <- generator do
      assert is_atom(value)
    end
  end
end
