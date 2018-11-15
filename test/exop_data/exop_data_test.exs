defmodule ExopDataTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  property "Custom generator" do
    contract = [%{name: :a, opts: [type: :string, format: ~r/@/]}]
    domains = ["gmail.com", "hotmail.com", "yahoo.com"]

    email_generator =
      gen all name <- StreamData.string(:alphanumeric),
              name != "",
              domain <- StreamData.member_of(domains) do
        name <> "@" <> domain
      end

    check all params <- ExopData.generate(contract, generators: %{a: email_generator}) do
      assert is_nil(params[:a]) || Regex.match?(~r/@/, params[:a])
    end
  end

  property "Format" do
    contract = [%{name: :a, opts: [type: :string, format: ~r/@/]}]

    check all params <- ExopData.generate(contract) do
      assert is_nil(params[:a]) || Regex.match?(~r/@/, params[:a])
    end
  end

  property "integers with numericality" do
    contract = [
      %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
      %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
    ]

    check all %{a: a, b: b} <- ExopData.generate(contract) do
      assert is_integer(a)
      assert is_integer(b)
    end
  end

  property "simple strings" do
    contract = [
      %{name: :a, opts: [type: :string]},
      %{name: :b, opts: [type: :string]}
    ]

    check all params <- ExopData.generate(contract) do
      assert is_nil(params[:a]) || is_binary(params[:a])
      assert is_nil(params[:b]) || is_binary(params[:b])
    end
  end

  describe "with common filters" do
    property "in" do
      contract = [
        %{name: :a, opts: [required: true, exactly: :aaa]},
        %{name: :b, opts: [required: true, in: [:bb, :bbb, :bbbb]]},
        %{name: :c, opts: [required: true, type: :atom, not_in: [:a, :b, :c]]}
      ]

      check all %{a: a, b: b, c: c} <- ExopData.generate(contract) do
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
      contract = [
        %{
          name: :a,
          opts: [
            type: :map,
            required: true,
            inner: %{
              b: [type: :integer, required: true],
              c: [type: :string, required: true]
            }
          ]
        }
      ]

      check all %{a: %{b: b, c: c}} <- ExopData.generate(contract) do
        assert is_integer(b)
        assert is_binary(c)
      end
    end
  end

  describe "Custom generator option" do
    property "simple" do
      contract = [%{name: :a, opts: [type: :string, format: ~r/@/]}]
      domains = ["gmail.com", "hotmail.com", "yahoo.com"]

      email_generator =
        gen all name <- StreamData.string(:alphanumeric),
                name != "",
                domain <- StreamData.member_of(domains) do
          name <> "@" <> domain
        end

      check all params <- ExopData.generate(contract, generators: %{a: email_generator}) do
        assert is_nil(params[:a]) || Regex.match?(~r/@/, params[:a])
      end
    end

    property "Map: with :inner" do
      contract = [
        %{
          name: :a,
          opts: [type: :map, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      custom_generator = StreamData.constant(%{b: :atom})

      check all params <- ExopData.generate(contract, generators: %{a: custom_generator}) do
        %{a: %{b: :atom}} = params
      end
    end

    property "List: with :inner" do
      contract = [
        %{
          name: :a,
          opts: [type: :list, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      custom_generator = StreamData.constant(b: :atom)

      check all params <- ExopData.generate(contract, generators: %{a: custom_generator}) do
        %{a: [b: :atom]} = params
      end
    end

    property "Map: with nested inner" do
      contract = [
        %{
          name: :a,
          opts: [type: :map, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      custom_generator = StreamData.constant(:atom)

      check all params <- ExopData.generate(contract, generators: %{a: %{b: custom_generator}}) do
        %{a: %{b: :atom}} = params
      end
    end

    property "List: with nested inner" do
      contract = [
        %{
          name: :a,
          opts: [type: :list, required: true, inner: %{b: [type: :atom, required: true]}]
        }
      ]

      custom_generator = StreamData.constant(:atom)

      check all params <- ExopData.generate(contract, generators: %{a: %{b: custom_generator}}) do
        %{a: [b: :atom]} = params
      end
    end

    property "Map: with twice-nested inner" do
      contract = [
        %{
          name: :a,
          opts: [
            type: :map,
            required: true,
            inner: %{b: [type: :map, required: true, inner: %{c: [type: :atom, required: true]}]}
          ]
        }
      ]

      custom_generator = StreamData.constant(:atom)

      check all params <-
                  ExopData.generate(contract, generators: %{a: %{b: %{c: custom_generator}}}) do
        %{a: %{b: %{c: :atom}}} = params
      end
    end

    property "List: with twice-nested inner" do
      contract = [
        %{
          name: :a,
          opts: [
            type: :list,
            required: true,
            inner: %{b: [type: :list, required: true, inner: %{c: [type: :atom, required: true]}]}
          ]
        }
      ]

      custom_generator = StreamData.constant(:atom)

      check all params <-
                  ExopData.generate(contract, generators: %{a: %{b: %{c: custom_generator}}}) do
        %{a: [b: [c: :atom]]} = params
      end
    end
  end
end
