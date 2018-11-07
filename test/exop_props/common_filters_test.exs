defmodule ExopProps.CommonFiltersTest do
  use ExUnit.Case, async: false
  use ExopProps

  describe "allow_nil" do
    property "generates at least one nil" do
      contract = [%{name: :a, opts: [type: :integer, allow_nil: true]}]

      check_list = contract |> exop_props() |> Enum.take(1000)

      assert Enum.any?(check_list, fn %{a: a} -> is_integer(a) end)
      assert Enum.any?(check_list, fn %{a: a} -> is_nil(a) end)
    end
  end
end
