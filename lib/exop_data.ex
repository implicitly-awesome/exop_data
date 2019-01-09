defmodule ExopData do
  @moduledoc """
  ExopData utilize the power of two libs: Exop & StreamData to help you write property-based tests.
  ExopData generates properties (essentially generates StreamData generators) based on Exop operation's
  contract.

  A contract is a list of maps `%{name: atom(), opts: keyword()}`, where each map represents
  a single parameter (`%{name: :param_a, opts: [type: :string, length: %{min: 1}]}`)

  For more information on Exop, operations, contracts and checks see https://github.com/madeinussr/exop
  """
  @type contract_item() :: %{name: atom(), opts: keyword()}
  @type contract() :: [contract_item()]

  @exop_types ~w(
    boolean
    integer
    float
    string
    tuple
    map
    struct
    keyword
    list
    atom
    module
    function
  )a

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

  def generator_for_opts(%{in: _values} = opts, _props_opts), do: resolve_in_list(opts)

  def generator_for_opts(%{format: regex}, _opts), do: resolve_format(regex)

  def generator_for_opts(%{regex: regex}, _opts), do: resolve_format(regex)

  def generator_for_opts(%{struct: %struct_module{}} = param_opts, opts) do
    param_opts
    |> Map.put(:struct, struct_module)
    |> generator_for_opts(opts)
  end

  def generator_for_opts(%{struct: struct_module} = param_opts, opts)
      when is_atom(struct_module) do
    param_opts
    |> Map.put(:struct_module, struct_module)
    |> run_generator(opts)
  end

  def generator_for_opts(param_opts, opts) when is_map(param_opts) do
    run_generator(param_opts, opts)
  end

  defp run_generator(param_opts, opts) do
    param_type = param_type(param_opts)

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
  defp param_type(%{struct: _}), do: :struct

  defp param_type(%{type: type}), do: type

  # with no :type specified, but with :inner a param is :map by default
  defp param_type(%{inner: _}), do: :map

  defp param_type(_), do: :term

  @spec optional_fields([map()]) :: [atom()]
  defp optional_fields(contract) do
    contract
    |> Stream.reject(fn
      %{name: _, opts: opts} when is_list(opts) -> Keyword.get(opts, :required, true)
      %{name: _, opts: opts} when is_map(opts) -> Map.get(opts, :required, true)
    end)
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

      some_value ->
        if has_generator?(some_value) do
          {param_name, build_generator(param_opts, Map.put(props_opts, :generators, some_value))}
        else
          {param_name, StreamData.constant(some_value)}
        end
    end
  end

  defp has_generator?(%{} = map), do: map |> Map.values() |> has_generator?()

  defp has_generator?([h | t]),
    do: match?(%StreamData{}, h) || has_generator?(h) || has_generator?(t)

  defp has_generator?(%StreamData{}), do: true
  defp has_generator?(_), do: false

  @spec build_generator(map(), map) :: StreamData.t()
  defp build_generator(param_opts, props_opts) do
    param_opts
    |> Enum.into(%{})
    |> generator_for_opts(props_opts)
  end

  @spec resolve_exact(any()) :: StreamData.t()
  defp resolve_exact(value), do: StreamData.constant(value)

  @spec resolve_in_list(list()) :: StreamData.t()
  defp resolve_in_list(%{type: type, in: values}) when is_list(values) and type in @exop_types do
    if Enum.all?(values, &check_type(&1, type)) do
      StreamData.member_of(values)
    else
      raise("""
      ExopData: not all :in check items are of the type :#{type}
      """)
    end
  end

  defp resolve_in_list(%{type: type, in: values}) when is_list(values) do
    raise("""
    ExopData: there is no generator for params of type :#{type},
    you can add your own clause for such params
    """)
  end

  defp resolve_in_list(%{in: values} = _opts) when is_list(values) do
    StreamData.member_of(values)
  end

  @spec resolve_format(Regex.t()) :: StreamData.t()
  defp resolve_format(regex), do: Randex.stream(regex, mod: Randex.Generator.StreamData)

  @spec check_type(any(), atom()) :: boolean()
  defp check_type(value, :boolean) when is_boolean(value), do: true
  defp check_type(value, :integer) when is_integer(value), do: true
  defp check_type(value, :float) when is_float(value), do: true
  defp check_type(value, :string) when is_binary(value), do: true
  defp check_type(value, :tuple) when is_tuple(value), do: true
  defp check_type(value, :map) when is_map(value), do: true
  defp check_type(value, :struct) when is_map(value), do: true
  defp check_type(value, :list) when is_list(value), do: true
  defp check_type(value, :atom) when is_atom(value), do: true
  defp check_type(value, :function) when is_function(value), do: true
  defp check_type([] = _value, :keyword), do: true
  defp check_type([{atom, _} | _] = _value, :keyword) when is_atom(atom), do: true

  defp check_type(value, :module) when is_atom(value) do
    Code.ensure_loaded?(value)
  end

  defp check_type(_, _), do: false
end
