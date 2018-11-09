defmodule ExopProps.ParamsGenerator.MapTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import ExopProps.ParamsGenerator.Map, only: [generate: 1]

  property "generates map generator" do
    check all value <- generate(%{}) do
      assert is_map(value)
    end
  end

  describe "with :length option" do
    property "is" do
      generator = generate(%{length: %{is: 5}})

      check all value <- generator do
        assert value |> Map.keys() |> length() == 5
      end
    end

    property "in" do
      generator = generate(%{length: %{in: 5..10}})

      check all value <- generator do
        assert value |> Map.keys() |> length() >= 5
        assert value |> Map.keys() |> length() <= 10
      end
    end

    property "min & max" do
      generator = generate(%{length: %{min: 5, max: 10}})

      check all value <- generator do
        assert value |> Map.keys() |> length() >= 5
        assert value |> Map.keys() |> length() <= 10
      end
    end

    property "min" do
      generator = generate(%{length: %{min: 5}})

      check all value <- generator do
        assert value |> Map.keys() |> length() >= 5
      end
    end

    property "max" do
      generator = generate(%{length: %{max: 5}})

      check all value <- generator do
        assert value |> Map.keys() |> length() <= 5
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

  describe "with :inner option" do
    property "simple" do
      generator = generate(@inner_opts_simple)

      check all value <- generator do
        %{a: a, b: b} = value
        assert is_integer(a)
        assert is_binary(b)
      end
    end

    property "with :min length" do
      generator = @inner_opts_simple |> Map.put(:length, %{min: 4}) |> generate()

      check all value <- generator do
        %{a: a, b: b} = value
        assert is_integer(a)
        assert is_binary(b)
        assert Enum.count(value) >= 4
      end
    end

    property "with :max length" do
      generator = @inner_opts_simple |> Map.put(:length, %{max: 4}) |> generate()

      check all value <- generator do
        %{a: a, b: b} = value
        assert is_integer(a)
        assert is_binary(b)
        assert Enum.count(value) <= 4
      end
    end

    property "with :in length" do
      generator = @inner_opts_simple |> Map.put(:length, %{in: 3..5}) |> generate()

      check all value <- generator do
        %{a: a, b: b} = value
        assert is_integer(a)
        assert is_binary(b)
        assert Enum.count(value) >= 3
        assert Enum.count(value) <= 5
      end
    end

    property "with :min & max length" do
      generator = @inner_opts_simple |> Map.put(:length, %{min: 3, max: 5}) |> generate()

      check all value <- generator do
        %{a: a, b: b} = value
        assert is_integer(a)
        assert is_binary(b)
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
              required: true,
              inner: %{
                c: [
                  required: true,
                  type: :atom
                ]
              }
            ],
            b: [
              required: true,
              type: :string
            ]
          }
        })

      check all value <- generator do
        %{a: %{c: c}, b: b} = value
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
              required: true,
              inner: %{
                c: [
                  type: :map,
                  required: true,
                  inner: %{
                    d: [
                      type: :integer,
                      required: true,
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
              required: true,
              type: :string
            ]
          }
        })

      check all value <- generator do
        %{a: %{c: %{d: d}}, b: b} = value
        assert is_integer(d)
        assert d >= 5
        assert d <= 10
        assert is_binary(b)
      end
    end
  end
end
