defmodule ExopProps.ParamsGenerator.BooleanTest do
  use ExUnit.Case, async: false
  import ExUnitProperties

  import ExopProps.ParamsGenerator.Boolean, only: [generate: 1]

  property "generates booleans" do
    generator = generate(%{})

    check all value <- generator do
      assert is_boolean(value)
    end
  end
end
