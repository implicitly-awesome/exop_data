defmodule ExopProps.ParamsGenerator.MapTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  import ExopProps.ParamsGenerator.Map, only: [generate: 1]

  property "generates map generator" do
    check all value <- generate([]) do
      assert is_map(value)
    end

    # NOTE: this is extremly slow
    # check all value <- StreamData.map_of(StreamData.term(), StreamData.term()) do
    #   assert true
    # end
  end

  describe "with :length option" do
    property "is" do
      generator = generate(length: %{is: 5})

      check all value <- generator do
        assert value |> Map.keys() |> length() == 5
      end
    end

    property "in" do
      generator = generate(length: %{in: 5..10})

      check all value <- generator do
        assert value |> Map.keys() |> length() >= 5
        assert value |> Map.keys() |> length() <= 10
      end
    end

    property "min & max" do
      generator = generate(length: %{min: 5, max: 10})

      check all value <- generator do
        assert value |> Map.keys() |> length() >= 5
        assert value |> Map.keys() |> length() <= 10
      end
    end

    property "min" do
      # NOTE: slow
      generator = generate(length: %{min: 5})

      check all value <- generator do
        assert value |> Map.keys() |> length() >= 5
      end
    end

    property "max" do
      generator = generate(length: %{max: 5})

      check all value <- generator do
        assert value |> Map.keys() |> length() <= 5
      end
    end
  end

  describe "with :inner option" do
    # TODO:
  end
end
