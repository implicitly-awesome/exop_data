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
      %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
      %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
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
        %{name: :a, opts: [required: true, exactly: :aaa]},
        %{name: :b, opts: [required: true, in: [:bb, :bbb, :bbbb]]},
        %{name: :c, opts: [required: true, type: :atom, not_in: [:a, :b, :c]]}
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
        %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
        %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
      ]

      check all %{a: a, b: b} <- generate(contract) do
        assert is_integer(a)
        assert is_integer(b)
        assert a > 0
        assert b > 10
      end
    end

    property "equals filter" do
      check all %{a: a} <- generate([%{name: :a, opts: [required: true, equals: 1]}]) do
        assert 1 == a
      end
    end

    property "exactly filter" do
      check all %{a: a} <- generate([%{name: :a, opts: [required: true, exactly: 1]}]) do
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
            required: true,
            inner: %{
              b: [type: :integer, required: true],
              c: [type: :string, required: true]
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

  describe "Custom generator option" do
    setup do
      {:ok, simple: StreamData.constant(:atom)}
    end

    property "simple", %{simple: generator} do
      contract = [%{name: :a, opts: [type: :atom, required: true]}]

      check all params <- generate(contract, generators: %{a: generator}) do
        assert %{a: :atom} == params
      end
    end

    property "Map: with :inner" do
      contract = [
        %{
          name: :a,
          opts: [type: :map, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      custom_generator = StreamData.constant(%{b: :atom})

      check all params <- generate(contract, generators: %{a: custom_generator}) do
        assert %{a: %{b: :atom}} = params
      end
    end

    property "List: with :inner" do
      contract = [
        %{
          name: :a,
          opts: [type: :list, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      custom_generator = StreamData.constant(b: :atom)

      check all params <- generate(contract, generators: %{a: custom_generator}) do
        assert %{a: [b: :atom]} = params
      end
    end

    property "Map: with nested inner", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [type: :map, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      check all params <- generate(contract, generators: %{a: %{b: generator}}) do
        assert %{a: %{b: :atom}} = params
      end
    end

    property "List: with nested inner", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [type: :list, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      check all params <- generate(contract, generators: %{a: %{b: generator}}) do
        assert %{a: [b: :atom]} = params
      end
    end

    property "Map: with twice-nested inner", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :map,
            required: true,
            inner: %{b: [type: :map, required: true, inner: %{c: [type: :atom, required: true]}]}
          ]
        }
      ]

      check all params <- generate(contract, generators: %{a: %{b: %{c: generator}}}) do
        assert %{a: %{b: %{c: :atom}}} = params
      end
    end

    property "List: with twice-nested inner", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            required: true,
            inner: %{b: [type: :list, required: true, inner: %{c: [type: :atom, required: true]}]}
          ]
        }
      ]

      check all params <- generate(contract, generators: %{a: %{b: %{c: generator}}}) do
        assert %{a: [b: [c: :atom]]} = params
      end
    end

    property "List: list_item with one level", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            length: %{is: 2},
            list_item: [type: :atom]
          ]
        }
      ]

      check all %{a: params} <- generate(contract, generators: %{a: [generator]}) do
        assert [:atom, :atom] == params
      end
    end

    property "List: list_item with two levels", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            length: %{is: 1},
            list_item: [type: :list, length: %{is: 1}, list_item: [type: :atom]]
          ]
        }
      ]

      check all %{a: params} <- generate(contract, generators: %{a: [[generator]]}) do
        assert [[:atom]] == params
      end
    end

    property "List: list_item with inner", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            length: %{is: 1},
            list_item: [
              type: :map,
              inner: %{
                key: [type: :atom, required: true]
              }
            ]
          ]
        }
      ]

      check all %{a: params} <- generate(contract, generators: %{a: [%{key: generator}]}) do
        assert [%{key: :atom}] = params
      end
    end

    property "List: generator list_item", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            length: %{is: 1},
            list_item: [
              type: :map,
              inner: %{
                key: [type: :atom, required: true]
              }
            ]
          ]
        }
      ]

      check all %{a: value} <-
                  generate(contract, generators: %{a: StreamData.list_of(generator, length: 1)}) do
        assert [:atom] == value
      end
    end

    property "List: two list_items with inner", %{simple: generator} do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            length: %{is: 1},
            list_item: [
              type: :list,
              length: %{is: 1},
              list_item: [
                type: :map,
                inner: %{
                  key: [type: :atom, required: true]
                }
              ]
            ]
          ]
        }
      ]

      check all %{a: a} <- generate(contract, generators: %{a: [[%{key: generator}]]}) do
        assert [[%{key: :atom}]] = a
      end
    end

    property "Several inners" do
      contract = [
        %{
          name: :one,
          opts: [
            type: :map,
            required: true,
            inner: %{
              b: [type: :atom, required: true],
              c: [type: :map, required: true, inner: %{e: [type: :atom, required: true]}],
              d: [type: :atom, required: true]
            }
          ]
        },
        %{
          name: :two,
          opts: [
            type: :map,
            required: true,
            inner: %{
              b: [type: :atom, required: true],
              c: [type: :atom, required: true],
              d: [type: :integer, required: true, exactly: 1]
            }
          ]
        }
      ]

      b = StreamData.constant(:b)
      d = StreamData.constant(:d)
      e = StreamData.constant(:e)

      check all params <-
                  generate(
                    contract,
                    generators: %{one: %{b: b, d: d, c: %{e: e}}, two: %{b: e, c: b}}
                  ) do
        assert %{
                 one: %{b: :b, c: %{e: :e}, d: :d},
                 two: %{b: :e, c: :b, d: 1}
               } == params
      end
    end
  end

  defmodule TestStruct do
    defstruct ~w(a b c)a
  end

  property "struct check with inner" do
    contract = [
      %{
        name: :struct_param,
        opts: [
          struct: %TestStruct{},
          required: true,
          inner: %{
            a: [type: :string, required: true],
            b: [type: :atom]
          }
        ]
      }
    ]

    check all params <- generate(contract) do
      %{struct_param: %TestStruct{a: a}} = params

      assert is_binary(a)
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
        %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]}
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

  @skip true
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
end
