defmodule ExopProps.ParamsGenerator.Struct do
  @moduledoc """
  Implements ExopProps generators behaviour for `struct` parameter type.
  """

  alias Code.Typespec

  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(%{struct_module: struct_module}) do
    struct_module
    |> do_generate()
    |> StreamData.map(fn map -> struct!(struct_module, map) end)
  end

  defp do_generate(struct_module) do
    with {:ok, types} <- Typespec.fetch_types(struct_module),
         {:t, spec, _} <- Keyword.get(types, :type),
         {:ok, generator} <- spec_generator(struct_module, spec, types) do
      generator
    else
      _ -> random_data_generator(struct_module)
    end
  end

  defp spec_generator(_struct_module, {:type, _, _, definition}, _types) do
    {params, custom_generators} =
      definition
      |> Enum.filter(fn
        {:type, _, :map_field_exact, [{:atom, _, :__struct__}, _]} -> false
        {:type, _, :map_field_exact, _} -> true
        _ -> false
      end)
      |> Enum.reduce({[], %{}}, fn {_, _, _, [{_, _, field}, {_, _, type, _}]},
                                   {acc, generators} ->
        {opts, generator} = type_options(type)

        params = [%{name: field, opts: opts} | acc]

        case generator do
          nil -> {params, generators}
          _ -> {params, Map.put(generators, field, generator)}
        end
      end)

    {:ok, ExopProps.exop_props(params, generators: custom_generators)}
  end

  defp type_options(type) when type in [:pid, :any, :term, :module, :maybe_improper_list] do
    {[required: true], type_generator(type)}
  end

  defp type_options(type), do: {type_opts(type), nil}

  defp type_opts(:node), do: type_opts(:atom)

  defp type_opts(:binary), do: type_opts(:string)

  defp type_opts(:bitstring), do: type_opts(:binary)

  defp type_opts(:iodata), do: type_opts(:binary)

  defp type_opts(:iolist), do: type_opts(:binary)

  defp type_opts(:number), do: type_opts(:integer)

  defp type_opts(:neg_integer), do: [numericality: %{max: -1}] ++ type_opts(:integer)

  defp type_opts(:non_neg_integer), do: [numericality: %{min: 0}] ++ type_opts(:integer)

  defp type_opts(:pos_integer), do: [numericality: %{min: 1}] ++ type_opts(:integer)

  defp type_opts(:arity), do: type_opts(:byte)

  defp type_opts(:byte), do: [numericality: %{min: 0, max: 255}] ++ type_opts(:integer)

  defp type_opts(type), do: [required: true, type: type]

  defp type_generator(type) when type in [:any, :term] do
    StreamData.term()
  end

  defp type_generator(:pid) do
    {StreamData.integer(1..255), StreamData.integer(1..255)}
    |> StreamData.tuple()
    |> StreamData.map(fn {n, m} -> pid(0, n, m) end)
  end

  defp type_generator(:maybe_improper_list) do
    proper_list = StreamData.list_of(StreamData.binary())

    StreamData.one_of([proper_list, StreamData.constant([1 | 1])])
  end

  defp type_generator(:module) do
    StreamData.atom(:alias)
  end

  defp random_data_generator(struct_module) do
    struct = struct!(struct_module, %{})
    keys = struct |> Map.keys() |> List.delete(:__struct__)

    keys
    |> Enum.into(%{}, fn key -> {key, StreamData.term()} end)
    |> StreamData.fixed_map()
  end

  defp pid(x, y, z)
       when is_integer(x) and x >= 0 and is_integer(y) and y >= 0 and is_integer(z) and z >= 0 do
    :erlang.list_to_pid(
      '<' ++
        Integer.to_charlist(x) ++
        '.' ++ Integer.to_charlist(y) ++ '.' ++ Integer.to_charlist(z) ++ '>'
    )
  end
end
