defmodule ExopProps.ParamsGenerator.StructTest do
  use ExUnit.Case, async: true
  use ExopProps

  defmodule StructOperation do
    use Exop.Operation

    parameter(:a, required: true, struct: %StructWithTypespecs{})

    def process(params) do
      params[:a]
    end
  end

  property "generates struct" do
    check all %{a: value} <- exop_props(StructOperation) do
      assert %StructWithTypespecs{} = value

      assert is_atom(value.atom)
      assert is_map(value.map)
      assert is_tuple(value.tuple)
      assert is_binary(value.binary)
      assert is_binary(value.iodata)
      assert is_binary(value.bitstring)
      assert is_binary(value.iolist)
      assert is_integer(value.integer)
      assert is_integer(value.number)
      assert is_float(value.float)
      assert is_boolean(value.boolean)
      assert is_list(value.list)
      assert is_list(value.maybe_improper_list)

      assert is_integer(value.neg_integer) && value.neg_integer < 0
      assert is_integer(value.non_neg_integer) && value.non_neg_integer >= 0
      assert is_integer(value.pos_integer) && value.pos_integer >= 1
      assert is_integer(value.byte) && value.byte in 0..255
      assert is_integer(value.arity) && value.arity in 0..255

      assert is_atom(value.node)
      assert is_pid(value.pid)
      assert Map.has_key?(value, :any)
      assert Map.has_key?(value, :term)
      assert is_atom(value.module)
    end
  end
end
