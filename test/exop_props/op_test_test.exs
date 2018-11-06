defmodule OpTest.OpTestTest do
  use ExUnit.Case, async: false
  use ExopProps

  defmodule Multiply do
    use Exop.Operation

    parameter(:a, required: true, type: :integer, numericality: %{greater_than: 0})
    parameter(:b, required: true, type: :integer, numericality: %{greater_than: 10})

    def process(params) do
      params[:a] * params[:b]
    end
  end

  defmodule Concatenate do
    use Exop.Operation

    parameter(:a, type: :string)
    parameter(:b, type: :string)

    def process(params) do
      params[:a] <> params[:b]
    end
  end

  defmodule Common do
    use Exop.Operation

    parameter(:a, exact: :aaa)
    parameter(:b, in: [:bb, :bbb, :bbbb])
    parameter(:c, type: :atom, not_in: [:a, :b, :c])

    def process(params), do: params
  end

  property "Multiply" do
    check all %{a: a, b: b} = params <- params(Multiply) do
      result = Multiply.run!(params)
      expected_result = a * b
      assert result == expected_result
    end
  end

  property "Concatenate" do
    check all %{a: a, b: b} = params <- params(Concatenate) do
      result = Concatenate.run!(params)
      expected_result = a <> b
      assert result == expected_result
    end
  end

  describe "with common filters" do
    property "in" do
      check all %{a: a, b: b, c: c} = _params <- params(Common) do
        assert a == :aaa
        assert b in [:bb, :bbb, :bbbb]
        assert c not in [:a, :b, :c]
      end
    end
  end
end
