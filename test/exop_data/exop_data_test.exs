defmodule ExopDataTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import ExopData

  property "Format" do
    contract = [%{name: :a, opts: [type: :string, format: ~r/@/]}]

    check all params <- generate(contract) do
      assert is_nil(params[:a]) || Regex.match?(~r/@/, params[:a])
    end
  end

  property "integers with numericality" do
    contract = [
      %{name: :a, opts: [type: :integer, numericality: %{greater_than: 0}]},
      %{name: :b, opts: [type: :integer, numericality: %{greater_than: 10}]}
    ]

    check all %{a: a, b: b} <- generate(contract) do
      assert is_integer(a)
      assert is_integer(b)
    end
  end

  property "simple strings" do
    contract = [
      %{name: :a, opts: [type: :string]},
      %{name: :b, opts: [type: :string]}
    ]

    check all params <- generate(contract) do
      assert is_nil(params[:a]) || is_binary(params[:a])
      assert is_nil(params[:b]) || is_binary(params[:b])
    end
  end

  describe "with common filters" do
    property "in" do
      contract = [
        %{name: :a, opts: [exactly: :aaa]},
        %{name: :b, opts: [in: [:bb, :bbb, :bbbb]]},
        %{name: :c, opts: [type: :atom, not_in: [:a, :b, :c]]}
      ]

      check all %{a: a, b: b, c: c} <- generate(contract) do
        assert a == :aaa
        assert b in [:bb, :bbb, :bbbb]
        assert c not in [:a, :b, :c]
      end
    end
  end

  describe "with contract passed instead of an operation" do
    property "just contract" do
      contract = [
        %{name: :a, opts: [type: :integer, numericality: %{greater_than: 0}]},
        %{name: :b, opts: [type: :integer, numericality: %{greater_than: 10}]}
      ]

      check all %{a: a, b: b} <- generate(contract) do
        assert is_integer(a)
        assert is_integer(b)
        assert a > 0
        assert b > 10
      end
    end

    property "equals filter" do
      check all %{a: a} <- generate([%{name: :a, opts: [equals: 1]}]) do
        assert 1 == a
      end
    end

    property "exactly filter" do
      check all %{a: a} <- generate([%{name: :a, opts: [exactly: 1]}]) do
        assert 1 == a
      end
    end
  end

  describe "map type with inner opts" do
    property "simple" do
      contract = [
        %{
          name: :a,
          opts: [
            type: :map,
            inner: %{
              b: [type: :integer],
              c: [type: :string]
            }
          ]
        }
      ]

      check all %{a: %{b: b, c: c}} <- generate(contract) do
        assert is_integer(b)
        assert is_binary(c)
      end
    end
  end

  describe "test struct" do
    defmodule TestStruct do
      defstruct ~w(string atom)a
    end

    property "with inner" do
      contract = [
        %{
          name: :struct_param,
          opts: [
            struct: %TestStruct{},
            inner: %{
              string: [type: :string],
              atom: [type: :atom]
            }
          ]
        }
      ]

      check all params <- generate(contract) do
        %{struct_param: %TestStruct{string: string, atom: atom}} = params

        assert is_binary(string)
        assert is_atom(atom)
      end
    end

    property "defined as atom" do
      contract = [%{name: :struct_param, opts: [struct: TestStruct]}]

      check all %{struct_param: struct_param} <- generate(contract) do
        assert %TestStruct{} = struct_param
      end
    end
  end

  describe "with required check" do
    property "a parameter is required by default" do
      contract = [%{name: :a, opts: [type: :integer, numericality: %{greater_than: 0}]}]

      check all %{a: a} <- generate(contract) do
        assert is_integer(a) && a > 0
      end
    end

    property "a parameter is required explicitly" do
      contract = [
        %{name: :a, opts: [type: :integer, numericality: %{greater_than: 0}]}
      ]

      check all %{a: a} <- generate(contract) do
        assert is_integer(a) && a > 0
      end
    end

    property "a parameter is not required explicitly" do
      contract = [
        %{name: :a, opts: [required: false, type: :integer, numericality: %{greater_than: 0}]},
        %{name: :b, opts: [type: :integer, numericality: %{greater_than: 10}]}
      ]

      check all params <- generate(contract) do
        assert is_nil(params[:a]) || (is_integer(params[:a]) && params[:a] > 0)
        assert is_integer(params[:b]) && params[:b] > 10
      end
    end
  end

  property "nested list_item speed test" do
    contract = [
      %{
        name: :complex_param,
        opts: [
          type: :map,
          inner: %{
            a: [type: :integer, numericality: %{in: 10..100}],
            b: [type: :map, inner: %{d: [type: :string, length: %{is: 12}]}],
            # c: [type: :list, list_item: %{type: :atom}]
            # c: [type: :list, list_item: %{type: :list, list_item: %{type: :string}}]
            c: [
              type: :list,
              list_item: %{
                type: :map,
                inner: %{d: [type: :map, inner: %{e: [type: :list, list_item: %{type: :atom}]}]}
              }
            ]
            # c: [type: :list, list_item: %{type: :map, inner: %{d: [type: :map, inner: %{e: [type: :map, inner: %{f: [type: :atom]}]}]}}]
            # c: [type: :map, inner: %{d: [type: :map, inner: %{e: [type: :map, inner: %{f: [type: :atom]}]}]}]
          }
        ]
      }
    ]

    check all params <- generate(contract) do
      # obviously true
      assert is_map(params.complex_param)
    end
  end

  property "param without :type but with :inner opt is :map by default" do
    contract = [
      %{
        name: :a,
        opts: [
          inner: %{b: [type: :atom], c: [type: :string]}
        ]
      }
    ]

    check all %{a: %{b: b, c: c}} <- ExopData.generate(contract) do
      assert is_atom(b)
      assert is_binary(c)
    end
  end

  describe "param with :type & :in checks" do
    property "if :in items are all values of the provided :type " do
      contract = [
        %{
          name: :a,
          opts: [type: :atom, in: [:a, :b, :c, :d]]
        }
      ]

      check all %{a: a} <- ExopData.generate(contract) do
        assert is_atom(a)
        assert a in [:a, :b, :c, :d]
      end
    end

    property "if :in items aren't all values of the provided :type " do
      contract = [
        %{
          name: :a,
          opts: [type: :atom, in: [:a, :b, "c", :d]]
        }
      ]

      assert_raise RuntimeError,
                   "ExopData: not all :in check items are of the type :atom\n",
                   fn ->
                     ExopData.generate(contract)
                   end
    end
  end
end
