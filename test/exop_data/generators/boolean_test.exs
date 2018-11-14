defmodule ExopData.Generators.BooleanTest do
  use ExUnit.Case, async: true
  import ExUnitProperties

  import ExopData.Generators.Boolean, only: [generate: 1]

  property "generates booleans" do
    generator = generate(%{})

    check all value <- generator do
      assert is_boolean(value)
    end
  end
end
