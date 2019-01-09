defmodule ExopData.Generators.ListTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import ExopData.Generators.List, only: [generate: 1]

  property "generates list generator" do
    check all value <- generate(%{}) do
      assert is_list(value)
    end
  end

  describe "with :length option" do
    property "is" do
      generator = generate(%{length: %{is: 5}})

      check all value <- generator do
        assert length(value) == 5
      end
    end

    property "in" do
      generator = generate(%{length: %{in: 5..10}})

      check all value <- generator do
        assert length(value) >= 5
        assert length(value) <= 10
      end
    end

    property "min & max" do
      generator = generate(%{length: %{min: 5, max: 10}})

      check all value <- generator do
        assert length(value) >= 5
        assert length(value) <= 10
      end
    end

    property "min" do
      generator = generate(%{length: %{min: 5}})

      check all value <- generator do
        assert length(value) >= 5
      end
    end

    property "max" do
      generator = generate(%{length: %{max: 5}})

      check all value <- generator do
        assert length(value) <= 5
      end
    end
  end

  describe "with :list_item option" do
    property ":type" do
      generator = generate(%{list_item: %{type: :integer}, length: %{min: 1}})

      check all value <- generator do
        assert value |> Enum.take_random(1) |> Enum.at(0) |> is_integer()
      end
    end

    property ":numericality" do
      generator =
        generate(%{
          list_item: %{
            type: :integer,
            numericality: %{greater_than: 10, less_than_or_equal_to: 100}
          },
          length: %{min: 1}
        })

      check all value <- generator do
        random_item = value |> Enum.take_random(1) |> Enum.at(0)
        assert is_integer(random_item)
        assert random_item > 10
        assert random_item <= 100
      end
    end

    property ":length" do
      generator = generate(%{list_item: %{type: :string, length: %{in: 1..5}}, length: %{min: 1}})

      check all value <- generator do
        random_item = value |> Enum.take_random(1) |> Enum.at(0)
        assert is_binary(random_item)
        assert String.length(random_item) >= 1
        assert String.length(random_item) <= 5
      end
    end

    property ":inner" do
      generator =
        generate(%{
          length: %{min: 1},
          list_item: %{type: :map, inner: %{a: [type: :atom]}}
        })

      check all value <- generator do
        random_item = value |> Enum.take_random(1) |> Enum.at(0)
        %{a: a} = random_item
        assert is_atom(a)
      end
    end
  end

  @inner_opts_simple %{
    inner: %{
      a: [
        type: :integer,
        required: true
      ],
      b: [
        type: :string,
        required: true
      ]
    }
  }

  describe "with :inner option (Keyword)" do
    property "simple" do
      generator = generate(@inner_opts_simple)

      check all value <- generator do
        [{:a, a}, {:b, b}] = value
        assert is_integer(a)
        assert is_binary(b)
      end
    end

    property "with :min length" do
      generator = @inner_opts_simple |> Map.put(:length, %{min: 4}) |> generate()

      check all value <- generator do
        assert value |> Keyword.get(:a) |> is_integer()
        assert value |> Keyword.get(:b) |> is_binary()
        assert Enum.count(value) >= 4
      end
    end

    property "with :max length" do
      generator = @inner_opts_simple |> Map.put(:length, %{max: 4}) |> generate()

      check all value <- generator do
        assert value |> Keyword.get(:a) |> is_integer()
        assert value |> Keyword.get(:b) |> is_binary()
        assert Enum.count(value) <= 4
      end
    end

    property "with :in length" do
      generator = @inner_opts_simple |> Map.put(:length, %{in: 3..5}) |> generate()

      check all value <- generator do
        assert value |> Keyword.get(:a) |> is_integer()
        assert value |> Keyword.get(:b) |> is_binary()
        assert Enum.count(value) >= 3
        assert Enum.count(value) <= 5
      end
    end

    property "with :min & max length" do
      generator = @inner_opts_simple |> Map.put(:length, %{min: 3, max: 5}) |> generate()

      check all value <- generator do
        assert value |> Keyword.get(:a) |> is_integer()
        assert value |> Keyword.get(:b) |> is_binary()
        assert Enum.count(value) >= 3
        assert Enum.count(value) <= 5
      end
    end

    property "with embedded inner" do
      generator =
        generate(%{
          inner: %{
            a: [
              type: :map,
              inner: %{
                c: [
                  type: :atom
                ]
              }
            ],
            b: [
              type: :string
            ]
          }
        })

      check all value <- generator do
        [{:a, %{c: c}}, {:b, b}] = value
        assert is_atom(c)
        assert is_binary(b)
      end
    end

    property "with embedded inner 2" do
      generator =
        generate(%{
          inner: %{
            a: [
              type: :map,
              inner: %{
                c: [
                  type: :map,
                  inner: %{
                    d: [
                      type: :integer,
                      numericality: %{
                        min: 5,
                        max: 10
                      }
                    ]
                  }
                ]
              }
            ],
            b: [
              type: :string
            ]
          }
        })

      check all value <- generator do
        [{:a, %{c: %{d: d}}}, {:b, b}] = value
        assert is_integer(d)
        assert d >= 5
        assert d <= 10
        assert is_binary(b)
      end
    end
  end
end
