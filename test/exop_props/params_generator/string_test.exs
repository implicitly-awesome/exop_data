defmodule ExopProps.ParamsGenerator.StringTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  import ExopProps.ParamsGenerator.String, only: [generate: 1]

  property "generates string generator" do
    check all value <- generate(%{}) do
      assert is_binary(value)
    end
  end

  describe "with :length option" do
    property "is" do
      generator = generate(%{length: %{is: 5}})

      check all value <- generator do
        assert String.length(value) == 5
      end
    end

    property "in" do
      generator = generate(%{length: %{in: 5..10}})

      check all value <- generator do
        assert String.length(value) >= 5
        assert String.length(value) <= 10
      end
    end

    property "min & max" do
      generator = generate(%{length: %{min: 5, max: 10}})

      check all value <- generator do
        assert String.length(value) >= 5
        assert String.length(value) <= 10
      end
    end

    property "min" do
      generator = generate(%{length: %{min: 5}})

      check all value <- generator do
        assert String.length(value) >= 5
      end
    end

    property "max" do
      generator = generate(%{length: %{max: 10}})

      check all value <- generator do
        assert String.length(value) <= 10
      end
    end
  end
end
