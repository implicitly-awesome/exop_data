defmodule ExopProps.ParamsGenerator do
  @moduledoc """
  Defines functions for generationg StreamData generator.
  """

  use ExUnitProperties

  alias ExopProps.{CommonFilters, CommonGenerators}

  @doc """
  Returns a StreamData generator for either an Exop operation or a contract.
  """
  @spec generate_for(module() | ExopProps.contract(), keyword()) :: StreamData.t()
  def generate_for(operation_or_contract, props_opts) when is_list(props_opts) do
    generate_for(operation_or_contract, Enum.into(props_opts, %{}))
  end

  def generate_for(operation, props_opts) when is_atom(operation) do
    {:module, operation} = Code.ensure_compiled(operation)
    generate_for(operation.contract(), props_opts)
  end

  def generate_for(contract, props_opts) when is_list(contract) do
    optional_keys = optional_fields(contract)

    contract
    |> Enum.into(%{}, &generator_for_param(&1, props_opts))
    |> CommonGenerators.map(optional_keys)
  end

  def generate_for(_, _) do
    raise("""
    ExopProps: please provide either an operation's contract
    or operation's module to make a generator
    """)
  end

  @doc """
  Returns a StreamData generator for parameter's opts and props opts given to ExopProps generator.
  """
  @spec generator_for_opts(map(), map()) :: StreamData.t()
  def generator_for_opts(%{equals: value}, _props_opts), do: resolve_exact(value)

  def generator_for_opts(%{exactly: value}, _props_opts), do: resolve_exact(value)

  def generator_for_opts(%{in: values}, _props_opts), do: resolve_in_list(values)

  def generator_for_opts(%{format: regex}, _opts), do: resolve_format(regex)

  def generator_for_opts(%{regex: regex}, _opts), do: resolve_format(regex)

  def generator_for_opts(param_opts, opts) when is_map(param_opts) do
    param_type = param_type(param_opts)

    param_opts =
      if Map.get(param_opts, :struct) do
        %struct_module{} = Map.get(param_opts, :struct)
        Map.put(param_opts, :struct_module, struct_module)
      else
        param_opts
      end

    generator_module =
      [
        ExopProps.ParamsGenerator,
        param_type |> Atom.to_string() |> String.capitalize()
      ]
      |> Module.concat()

    if Code.ensure_compiled?(generator_module) do
      generator_module
      |> apply(:generate, [param_opts, opts])
      |> CommonFilters.filter(param_opts)
    else
      raise("""
      ExopProps: there is no generator for params of type :#{param_type},
      you can add your own clause for such params
      """)
    end
  end

  @spec param_type(map()) :: atom()
  defp param_type(%{struct: %_{}}), do: :struct

  defp param_type(%{type: type}), do: type

  defp param_type(_), do: :term

  @spec optional_fields([map()]) :: [atom()]
  defp optional_fields(contract) do
    contract
    |> Stream.reject(&Keyword.get(&1.opts, :required, false))
    |> Stream.map(& &1.name)
    |> Enum.to_list()
  end

  @spec generator_for_param(ExopProps.contract_item(), map()) :: {atom(), StreamData.t()}
  defp generator_for_param(%{name: param_name, opts: param_opts}, props_opts) do
    generators = Map.get(props_opts, :generators, %{})

    case Map.get(generators, param_name) do
      %StreamData{} = param_generator ->
        {param_name, param_generator}
      _ ->
        {param_name, build_generator(param_opts, props_opts)}
    end
  end

  @spec build_generator(map(), map) :: StreamData.t()
  defp build_generator(param_opts, props_opts) do
    param_opts
    |> Enum.into(%{})
    |> generator_for_opts(props_opts)
  end

  @spec resolve_exact(any()) :: StreamData.t()
  defp resolve_exact(value), do: StreamData.constant(value)

  @spec resolve_in_list(list()) :: StreamData.t()
  defp resolve_in_list(in_list) when is_list(in_list), do: StreamData.member_of(in_list)

  defp resolve_format(regex), do: Randex.stream(regex, mod: Randex.Generator.StreamData)
end
