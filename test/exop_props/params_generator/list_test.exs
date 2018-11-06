defmodule ExopProps.ParamsGenerator.ListTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  import ExopProps.ParamsGenerator.List, only: [generate: 1]

  property "generates list generator" do
    check all value <- generate([]) do
      assert is_list(value)
    end
  end

  describe "with :length option" do
    property "is" do
      generator = generate(length: %{is: 5})

      check all value <- generator do
        assert length(value) == 5
      end
    end

    property "in" do
      generator = generate(length: %{in: 5..10})

      check all value <- generator do
        assert length(value) >= 5
        assert length(value) <= 10
      end
    end

    property "min & max" do
      generator = generate(length: %{min: 5, max: 10})

      check all value <- generator do
        assert length(value) >= 5
        assert length(value) <= 10
      end
    end

    property "min" do
      generator = generate(length: %{min: 5})

      check all value <- generator do
        assert length(value) >= 5
      end
    end

    property "max" do
      generator = generate(length: %{max: 5})

      check all value <- generator do
        assert length(value) <= 5
      end
    end
  end

  describe "with :inner option (for Keyword)" do
    # TODO:
  end

  describe "with :list_item option" do
    property ":type" do
      generator = generate(list_item: %{type: :integer}, length: %{min: 1})

      check all value <- generator do
        assert value |> Enum.take_random(1) |> Enum.at(0) |> is_integer()
      end
    end

    property ":numericality" do
      generator =
        generate(
          list_item: %{
            type: :integer,
            numericality: %{greater_than: 10, less_than_or_equal_to: 100}
          },
          length: %{min: 1}
        )

      check all value <- generator do
        random_item = value |> Enum.take_random(1) |> Enum.at(0)
        assert is_integer(random_item)
        assert random_item > 10
        assert random_item <= 100
      end
    end

    property ":length" do
      generator = generate(list_item: %{type: :string, length: %{in: 1..5}}, length: %{min: 1})

      check all value <- generator do
        random_item = value |> Enum.take_random(1) |> Enum.at(0)
        assert is_binary(random_item)
        assert String.length(random_item) >= 1
        assert String.length(random_item) <= 5
      end
    end
  end
end
