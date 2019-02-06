defmodule CheckOperationTest do
  use ExopData

  # a module to emulate Exop.Operation
  defmodule TestOp do
    def contract(), do: [%{name: :a, opts: [type: :string]}]
    def run(params), do: {:ok, "output #{params.a}"}
  end

  property "check_operation/3" do
    check_operation(TestOp, fn params ->
      assert is_map(params)
      {:ok, "output #{params.a}"}
    end)
  end

  property "check_operation/3 with custom generator" do
    domains = ["gmail.com", "hotmail.com", "yahoo.com"]

    email_generator =
      gen all name <- string(:alphanumeric),
              name != "",
              domain <- member_of(domains) do
        name <> "@" <> domain
      end

    custom_generators = %{a: email_generator}

    check_operation(TestOp, [generators: custom_generators], fn params ->
      last_part = params.a |> String.split("@") |> List.last()
      assert last_part in domains
      {:ok, "output #{params.a}"}
    end)
  end

  property "check_operation/3 with exact value" do
    custom_generators = %{a: "my string"}

    check_operation(TestOp, [generators: custom_generators], fn params ->
      assert params.a == "my string"
      {:ok, "output #{params.a}"}
    end)
  end
end
