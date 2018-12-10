defmodule ExopData.Generators.ModuleTest do
  use ExUnit.Case, async: true
  import ExUnitProperties

  import ExopData.Generators.Module, only: [generate: 1]

  property "generates compiled and loaded ExopData.FakeModule" do
    check all value <- generate(%{}) do
      assert ExopData.Generators.Module.ExopData.FakeModule == value
      assert Code.ensure_compiled?(value)
    end
  end
end
