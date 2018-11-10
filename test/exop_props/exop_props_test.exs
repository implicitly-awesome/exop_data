defmodule ExopPropsTest do
  use ExUnit.Case, async: true
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

  test "Custom generator" do
    domains = ["gmail.com", "hotmail.com", "yahoo.com"]

    email_generator =
      gen all name <- StreamData.string(:alphanumeric),
              name != "",
              domain <- StreamData.member_of(domains) do
        name <> "@" <> domain
      end

    check all params <- exop_props(Format, generators: %{a: email_generator}) do
      assert params == Format.run!(params)
    end
  end

  test "Format" do
    check all params <- exop_props(Format) do
      assert params == Format.run!(params)
    end
  end

  property "Multiply" do
    check all %{a: a, b: b} = params <- exop_props(Multiply) do
      result = Multiply.run!(params)
      expected_result = a * b
      assert result == expected_result
    end
  end

  property "Concatenate" do
    check all params <- exop_props(Concatenate) do
      result = Concatenate.run!(params)
      expected_result = params |> Map.values() |> Enum.join()
      assert result == expected_result
    end
  end

  describe "with common filters" do
    property "in" do
      check all %{a: a, b: b, c: c} <- exop_props(Common) do
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

      check all %{a: a, b: b} <- exop_props(contract) do
        assert is_integer(a)
        assert is_integer(b)
        assert a > 0
        assert b > 10
      end
    end

    property "equals filter" do
      check all %{a: a} <- exop_props([%{name: :a, opts: [required: true, equals: 1]}]) do
        assert 1 == a
      end
    end

    property "exactly filter" do
      check all %{a: a} <- exop_props([%{name: :a, opts: [required: true, exactly: 1]}]) do
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

      check all params <- exop_props(TestOp) do
        %{a: %{b: b, c: c}} = TestOp.run!(params)
        assert is_integer(b)
        assert is_binary(c)
      end
    end
  end

  defmodule Format do
    use Exop.Operation

    parameter(:a, type: :string, format: ~r/@/)

    def process(params), do: params
  end

  defmodule TestInner do
    use Exop.Operation

    parameter(:a, type: :map, required: true, inner: %{b: [type: :atom, required: true]})

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

      check all params <- exop_props(Format, generators: %{a: email_generator}) do
        assert params == Format.run!(params)
      end
    end

    property "with :inner" do
      map_generator = StreamData.constant(%{b: :atom})

      check all params <- exop_props(TestInner, generators: %{a: map_generator}) do
        %{a: %{b: :atom}} = TestInner.run!(params)
      end
    end

    # TODO:
    # property "with nested inner" do
    #   map_generator = StreamData.constant(:atom)

    #   check all params <- exop_props(TestInner, generators: %{b: map_generator}) do
    #     %{a: %{b: :atom}} = TestInner.run!(params)
    #   end
    # end
  end

  defmodule TestListItem do
    use Exop.Operation

    parameter(:a, type: :map, required: true, inner: %{b: [type: :atom, required: true]})
    # FIXME: required is ignored
    parameter(:b, type: :list, required: true, list_item: %{type: :atom, required: true})

    parameter(:c,
      type: :list,
      required: true,
      list_item: %{type: :map, required: true, inner: %{e: [type: :atom, required: true]}}
    )

    parameter(:d,
      type: :list,
      required: true,
      list_item: %{type: :tuple},
      inner: %{f: [type: :string, required: true]}
    )

    def process(params), do: params
  end

  property "sdf" do
    # exop_props(TestListItem) |> Enum.take(5) |> IO.inspect()
    # check all params <- exop_props(TestListItem) do
    #   %{a: %{b: b, c: c}} = TestListItem.run!(params)
    #   assert is_integer(b)
    #   assert is_binary(c)
    # end
  end
end
