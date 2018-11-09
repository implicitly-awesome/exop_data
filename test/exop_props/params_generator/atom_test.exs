defmodule ExopProps.ParamsGenerator.AtomTest do
  use ExUnit.Case, async: true
  import ExUnitProperties

  import ExopProps.ParamsGenerator.Atom, only: [generate: 1]

  property "generates atoms" do
    generator = generate(%{})

    check all value <- generator do
      assert is_atom(value)
    end
  end

  property "is" do
    generator = generate(%{length: %{is: 7}})

    check all value <- generator do
      assert is_atom(value)
      assert 7 == String.length(Atom.to_string(value))
    end
  end

  property "in" do
    generator = generate(%{length: %{in: 5..6}})

    check all value <- generator do
      assert is_atom(value)

      length = String.length(Atom.to_string(value))
      assert 5 <= length && length <= 6
    end
  end

  property "min" do
    generator = generate(%{length: %{min: 5}})

    check all value <- generator do
      assert is_atom(value)

      length = String.length(Atom.to_string(value))
      assert 5 <= length
    end
  end

  property "max" do
    generator = generate(%{length: %{max: 5}})

    check all value <- generator do
      assert is_atom(value)

      length = String.length(Atom.to_string(value))
      assert length <= 5
    end
  end

  property "min & max" do
    generator = generate(%{length: %{min: 5, max: 6}})

    check all value <- generator do
      assert is_atom(value)

      length = String.length(Atom.to_string(value))
      assert 5 <= length && length <= 6
    end
  end
end
