defmodule ExopData do
  @moduledoc """
  ExopData utilize the power of two libs: Exop & StreamData to help you write property-based tests.
  ExopData generates properties (essentially generates StreamData generators) based on Exop operation's
  contract.

  A contract is a list of maps `%{name: atom(), opts: keyword()}`, where each map represents
  a single parameter (`%{name: :param_a, opts: [type: :string, required: true, length: %{min: 1}]}`)

  For more information on Exop, operations, contracts and checks see https://github.com/madeinussr/exop
  """
  @type contract_item() :: %{name: atom(), opts: keyword()}
  @type contract() :: [contract_item()]

  alias ExopData.{CommonFilters, CommonGenerators}

  @doc """
  Returns a StreamData generator for either an Exop operation or a contract.
  """
  @spec generate(module() | ExopData.contract(), keyword()) :: StreamData.t()
  def generate(operation_or_contract, props_opts \\ [])

  def generate(operation_or_contract, props_opts) when is_list(props_opts) do
    generate(operation_or_contract, Enum.into(props_opts, %{}))
  end

  def generate(operation, props_opts) when is_atom(operation) do
    {:module, operation} = Code.ensure_compiled(operation)
    generate(operation.contract(), props_opts)
  end

  def generate(contract, props_opts) when is_list(contract) do
    optional_keys = optional_fields(contract)

    contract
    |> Enum.into(%{}, &generator_for_param(&1, props_opts))
    |> CommonGenerators.map(optional_keys)
  end

  def generate(_, _) do
    raise("""
    ExopData: please provide either an operation's contract
    or operation's module to make a generator
    """)
  end

  @doc """
  Returns a StreamData generator for parameter's opts and props opts given to ExopData generator.
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
        ExopData.Generators,
        param_type |> Atom.to_string() |> String.capitalize()
      ]
      |> Module.concat()

    if Code.ensure_compiled?(generator_module) do
      generator_module
      |> apply(:generate, [param_opts, opts])
      |> CommonFilters.filter(param_opts)
    else
      raise("""
      ExopData: there is no generator for params of type :#{param_type},
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

  @spec generator_for_param(ExopData.contract_item(), map()) :: {atom(), StreamData.t()}
  defp generator_for_param(%{name: param_name, opts: param_opts}, props_opts) do
    generators = Map.get(props_opts, :generators, %{})

    case Map.get(generators, param_name) do
      %StreamData{} = param_generator ->
        {param_name, param_generator}

      nil ->
        {param_name, build_generator(param_opts, Map.put(props_opts, :generators, %{}))}

      param_generators ->
        {param_name,
         build_generator(param_opts, Map.put(props_opts, :generators, param_generators))}
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
