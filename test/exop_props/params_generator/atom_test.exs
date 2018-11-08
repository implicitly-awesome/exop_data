defmodule ExopProps.ParamsGenerator.AtomTest do
  use ExUnit.Case, async: false
  import ExUnitProperties

  import ExopProps.ParamsGenerator.Atom, only: [generate: 1]

  property "generates atoms" do
    generator = generate(%{})

    check all value <- generator do
      assert is_atom(value)
    end
  end
end
