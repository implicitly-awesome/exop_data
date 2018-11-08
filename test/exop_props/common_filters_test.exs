defmodule ExopProps.CommonFiltersTest do
  use ExUnit.Case, async: false
  use ExopProps

  describe "allow_nil" do
    property "generates at least one nil" do
      contract = [%{name: :a, opts: [required: true, type: :integer, allow_nil: true]}]

      check_list = contract |> exop_props() |> Enum.take(1000)

      check_list_ints = Enum.filter(check_list, fn %{a: a} -> is_integer(a) end)
      check_list_nils = Enum.filter(check_list, fn %{a: a} -> is_nil(a) end)

      assert Enum.count(check_list_ints) > 0
      assert Enum.count(check_list_nils) > 0
      assert Enum.count(check_list) == Enum.count(check_list_ints) + Enum.count(check_list_nils)
    end
  end
end
