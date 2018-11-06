defmodule ExopProps.ParamsGenerator do
  use ExUnitProperties

  alias ExopProps.ParamsGenerator.CommonFilters

  def generate_for(contract) when is_list(contract) do
    Enum.reduce(contract, %{params: [], clauses: []}, &collect_params_clauses/2)
  end

  def generate_for(operation) when is_atom(operation) do
    {:module, operation} = Code.ensure_compiled(operation)
    generate_for(operation.contract())
  end

  def generate_for(_) do
    raise("""
    ExopProps: please provide either an operation's contract
    or operation's module to make a generator
    """)
  end

  defp collect_params_clauses(%{name: param_name, opts: param_opts} = _contract_item, acc) do
    param_opts = Enum.into(param_opts, [])
    exact_opt = Keyword.get(param_opts, :exact)
    in_list_opt = Keyword.get(param_opts, :in)
    param_opts_ast = param_opts_ast(param_opts)

    # TODO: required & default options
    # NOTE: what if generator is nil?
    # NOTE: mb move reolve_* to CommonFilters?
    generator =
      resolve_exact(exact_opt) || resolve_in_list(in_list_opt) || generator_quoted(param_opts_ast)

    param_clause = {:<-, [], [{param_name, [], nil}, generator]}

    acc
    |> Map.put(:params, [param_name | acc.params])
    |> Map.put(:clauses, [param_clause | acc.clauses])
  end

  defp param_opts_ast(param_opts) do
    Enum.map(param_opts, fn
      {name, value} when is_map(value) -> {name, {:%{}, [], param_opts_ast(value)}}
      {name, value} -> {name, value}
    end)
  end

  def generator(param_opts) do
    param_type = Keyword.get(param_opts, :type) || :term

    param_opts =
      if param_type == :struct && Keyword.get(param_opts, :struct) do
        %struct_module{} = Keyword.get(param_opts, :struct)
        Keyword.put(param_opts, :struct_module, struct_module)
      else
        Keyword.put(param_opts, :type, :map)
      end

    generator_module =
      [
        ExopProps.ParamsGenerator,
        param_type |> Atom.to_string() |> String.capitalize()
      ]
      |> Module.concat()

    if Code.ensure_compiled?(generator_module) do
      generator_module |> apply(:generate, [param_opts]) |> CommonFilters.filter(param_opts)
    else
      raise("""
      ExopProps: there is no generator for params of type :#{param_type},
      you can add your own clause for such params
      """)
    end
  end

  defp generator_quoted(param_opts) do
    quote bind_quoted: [param_opts: param_opts] do
      param_type = Keyword.get(param_opts, :type) || :term

      param_opts =
        if param_type == :struct && Keyword.get(param_opts, :struct) do
          %struct_module{} = Keyword.get(param_opts, :struct)
          Keyword.put(param_opts, :struct_module, struct_module)
        else
          Keyword.put(param_opts, :type, :map)
        end

      generator_module =
        Module.concat([
          ExopProps.ParamsGenerator,
          param_type |> Atom.to_string() |> String.capitalize()
        ])

      if Code.ensure_compiled?(generator_module) do
        generator_module |> apply(:generate, [param_opts]) |> CommonFilters.filter(param_opts)
      else
        raise("""
        ExopProps: there is no generator for params of type :#{param_type},
        you can add your own clause for such params
        """)
      end
    end
  end

  def resolve_exact(nil), do: nil

  def resolve_exact(value) do
    quote bind_quoted: [value: value] do
      StreamData.one_of([value])
    end
  end

  def resolve_in_list(in_list) when is_list(in_list) do
    quote bind_quoted: [in_list: in_list] do
      StreamData.one_of(in_list)
    end
  end

  def resolve_in_list(_), do: nil
end
