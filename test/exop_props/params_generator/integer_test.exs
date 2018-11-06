defmodule OpTest.ParamsGenerator.IntegerTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  import ExopProps.ParamsGenerator.Integer, only: [generate: 1]

  property "generates integer generator" do
    check all value <- generate([]) do
      assert is_integer(value)
    end
  end

  describe "with :numericality option" do
    property "equal_to" do
      generator = generate(numericality: %{equal_to: 12})

      check all value <- generator do
        assert value == 12
      end
    end

    property "greater_than" do
      generator = generate(numericality: %{greater_than: 1})

      check all value <- generator do
        assert value > 1
      end
    end

    property "greater_than_or_equal_to" do
      generator = generate(numericality: %{greater_than_or_equal_to: 1})

      check all value <- generator do
        assert value >= 1
      end
    end

    property "less_than" do
      generator = generate(numericality: %{less_than: 1})

      check all value <- generator do
        assert value < 1
      end
    end

    property "less_than_or_equal_to" do
      generator = generate(numericality: %{less_than_or_equal_to: 1})

      check all value <- generator do
        assert value <= 1
      end
    end

    property "equal_to & greater_than" do
      generator = generate(numericality: %{equal_to: 12, greater_than: 1})

      check all value <- generator do
        assert value == 12
      end
    end

    property "greater_than & less_than" do
      generator = generate(numericality: %{greater_than: 1, less_than: 3})

      check all value <- generator do
        assert value > 1
        assert value < 3
      end
    end

    property "greater_than_or_equal_to & less_than" do
      generator = generate(numericality: %{greater_than_or_equal_to: 1, less_than: 3})

      check all value <- generator do
        assert value >= 1
        assert value < 3
      end
    end

    property "greater_than_or_equal_to & less_than_or_equal_to" do
      generator = generate(numericality: %{greater_than_or_equal_to: 1, less_than_or_equal_to: 3})

      check all value <- generator do
        assert value >= 1
        assert value <= 3
      end
    end

    property "greater_than & less_than_or_equal_to" do
      generator = generate(numericality: %{greater_than: 1, less_than_or_equal_to: 3})

      check all value <- generator do
        assert value > 1
        assert value <= 3
      end
    end
  end
end
