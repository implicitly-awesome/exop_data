defmodule ExopData.Generators.IntegerTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import ExopData.Generators.Integer, only: [generate: 1]

  property "generates integer generator" do
    check all value <- generate(%{}) do
      assert is_integer(value)
    end
  end

  describe "with :numericality option" do
    property "equal_to" do
      generator = generate(%{numericality: %{equal_to: 12}})

      check all value <- generator do
        assert value == 12
      end
    end

    property "equals" do
      generator = generate(%{numericality: %{equals: 12}})

      check all value <- generator do
        assert value == 12
      end
    end

    property "is" do
      generator = generate(%{numericality: %{is: 12}})

      check all value <- generator do
        assert value == 12
      end
    end

    property "greater_than" do
      generator = generate(%{numericality: %{greater_than: 1}})

      check all value <- generator do
        assert value > 1
      end
    end

    property "gt" do
      generator = generate(%{numericality: %{gt: 1}})

      check all value <- generator do
        assert value > 1
      end
    end

    property "greater_than_or_equal_to" do
      generator = generate(%{numericality: %{greater_than_or_equal_to: 1}})

      check all value <- generator do
        assert value >= 1
      end
    end

    property "gte" do
      generator = generate(%{numericality: %{gte: 1}})

      check all value <- generator do
        assert value >= 1
      end
    end

    property "min" do
      generator = generate(%{numericality: %{min: 1}})

      check all value <- generator do
        assert value >= 1
      end
    end

    property "less_than" do
      generator = generate(%{numericality: %{less_than: 1}})

      check all value <- generator do
        assert value < 1
      end
    end

    property "lt" do
      generator = generate(%{numericality: %{lt: 1}})

      check all value <- generator do
        assert value < 1
      end
    end

    property "less_than_or_equal_to" do
      generator = generate(%{numericality: %{less_than_or_equal_to: 1}})

      check all value <- generator do
        assert value <= 1
      end
    end

    property "lte" do
      generator = generate(%{numericality: %{lte: 1}})

      check all value <- generator do
        assert value <= 1
      end
    end

    property "max" do
      generator = generate(%{numericality: %{max: 1}})

      check all value <- generator do
        assert value <= 1
      end
    end

    property "equal_to & greater_than" do
      generator = generate(%{numericality: %{equal_to: 12, greater_than: 1}})

      check all value <- generator do
        assert value == 12
      end
    end

    property "greater_than & less_than" do
      generator = generate(%{numericality: %{greater_than: 1, less_than: 3}})

      check all value <- generator do
        assert value > 1
        assert value < 3
      end
    end

    property "greater_than_or_equal_to & less_than" do
      generator = generate(%{numericality: %{greater_than_or_equal_to: 1, less_than: 3}})

      check all value <- generator do
        assert value >= 1
        assert value < 3
      end
    end

    property "greater_than_or_equal_to & less_than_or_equal_to" do
      generator =
        generate(%{numericality: %{greater_than_or_equal_to: 1, less_than_or_equal_to: 3}})

      check all value <- generator do
        assert value >= 1
        assert value <= 3
      end
    end

    property "greater_than & less_than_or_equal_to" do
      generator = generate(%{numericality: %{greater_than: 1, less_than_or_equal_to: 3}})

      check all value <- generator do
        assert value > 1
        assert value <= 3
      end
    end
  end
end
