defmodule ExopDataTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

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
      params
      |> Map.values()
      |> Enum.join()
    end
  end

  defmodule Common do
    use Exop.Operation

    parameter(:a, required: true, exactly: :aaa)
    parameter(:b, required: true, in: [:bb, :bbb, :bbbb])
    parameter(:c, required: true, type: :atom, not_in: [:a, :b, :c])

    def process(params), do: params
  end

  defmodule Format do
    use Exop.Operation

    parameter(:a, type: :string, format: ~r/@/)

    def process(params), do: params
  end

  property "Custom generator" do
    domains = ["gmail.com", "hotmail.com", "yahoo.com"]

    email_generator =
      gen all name <- StreamData.string(:alphanumeric),
              name != "",
              domain <- StreamData.member_of(domains) do
        name <> "@" <> domain
      end

    check all params <- ExopData.generate(Format, generators: %{a: email_generator}) do
      assert params == Format.run!(params)
    end
  end

  property "Format" do
    check all params <- ExopData.generate(Format) do
      assert params == Format.run!(params)
    end
  end

  property "Multiply" do
    check all %{a: a, b: b} = params <- ExopData.generate(Multiply) do
      result = Multiply.run!(params)
      expected_result = a * b
      assert result == expected_result
    end
  end

  property "Concatenate" do
    check all params <- ExopData.generate(Concatenate) do
      result = Concatenate.run!(params)
      expected_result = params |> Map.values() |> Enum.join()
      assert result == expected_result
    end
  end

  describe "with common filters" do
    property "in" do
      check all %{a: a, b: b, c: c} <- ExopData.generate(Common) do
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

      check all %{a: a, b: b} <- ExopData.generate(contract) do
        assert is_integer(a)
        assert is_integer(b)
        assert a > 0
        assert b > 10
      end
    end

    property "equals filter" do
      check all %{a: a} <- ExopData.generate([%{name: :a, opts: [required: true, equals: 1]}]) do
        assert 1 == a
      end
    end

    property "exactly filter" do
      check all %{a: a} <- ExopData.generate([%{name: :a, opts: [required: true, exactly: 1]}]) do
        assert 1 == a
      end
    end
  end

  describe "map type with inner opts" do
    property "simple" do
      defmodule TestOp do
        use Exop.Operation

        parameter(:a,
          type: :map,
          required: true,
          inner: %{
            b: [type: :integer, required: true],
            c: [type: :string, required: true]
          }
        )

        def process(params), do: params
      end

      check all params <- ExopData.generate(TestOp) do
        %{a: %{b: b, c: c}} = TestOp.run!(params)
        assert is_integer(b)
        assert is_binary(c)
      end
    end
  end

  defmodule TestInnerMap do
    use Exop.Operation

    parameter(:a, type: :map, required: true, inner: %{b: [type: :atom, required: true]})

    def process(params), do: params
  end

  defmodule TestInnerMap2 do
    use Exop.Operation

    parameter(:a,
      type: :map,
      required: true,
      inner: %{b: [type: :map, required: true, inner: %{c: [type: :atom, required: true]}]}
    )

    def process(params), do: params
  end

  defmodule TestInnerList do
    use Exop.Operation

    parameter(:a, type: :list, required: true, inner: %{b: [type: :atom, required: true]})

    def process(params), do: params
  end

  defmodule TestInnerList2 do
    use Exop.Operation

    parameter(:a,
      type: :list,
      required: true,
      inner: %{b: [type: :list, required: true, inner: %{c: [type: :atom, required: true]}]}
    )

    def process(params), do: params
  end

  describe "Custom generator option" do
    property "simple" do
      domains = ["gmail.com", "hotmail.com", "yahoo.com"]

      email_generator =
        gen all name <- StreamData.string(:alphanumeric),
                name != "",
                domain <- StreamData.member_of(domains) do
          name <> "@" <> domain
        end

      check all params <- ExopData.generate(Format, generators: %{a: email_generator}) do
        assert params == Format.run!(params)
      end
    end

    property "Map: with :inner" do
      custom_generator = StreamData.constant(%{b: :atom})

      check all params <- ExopData.generate(TestInnerMap, generators: %{a: custom_generator}) do
        %{a: %{b: :atom}} = TestInnerMap.run!(params)
      end
    end

    property "List: with :inner" do
      custom_generator = StreamData.constant(b: :atom)

      check all params <- ExopData.generate(TestInnerList, generators: %{a: custom_generator}) do
        %{a: [b: :atom]} = TestInnerList.run!(params)
      end
    end

    property "Map: with nested inner" do
      custom_generator = StreamData.constant(:atom)

      check all params <-
                  ExopData.generate(TestInnerMap, generators: %{a: %{b: custom_generator}}) do
        %{a: %{b: :atom}} = TestInnerMap.run!(params)
      end
    end

    property "List: with nested inner" do
      custom_generator = StreamData.constant(:atom)

      check all params <-
                  ExopData.generate(TestInnerList, generators: %{a: %{b: custom_generator}}) do
        %{a: [b: :atom]} = TestInnerList.run!(params)
      end
    end

    property "Map: with twice-nested inner" do
      custom_generator = StreamData.constant(:atom)

      check all params <-
                  ExopData.generate(TestInnerMap2, generators: %{a: %{b: %{c: custom_generator}}}) do
        %{a: %{b: %{c: :atom}}} = TestInnerMap2.run!(params)
      end
    end

    property "List: with twice-nested inner" do
      custom_generator = StreamData.constant(:atom)

      check all params <-
                  ExopData.generate(TestInnerList2, generators: %{a: %{b: %{c: custom_generator}}}) do
        %{a: [b: [c: :atom]]} = TestInnerList2.run!(params)
      end
    end
  end
end
