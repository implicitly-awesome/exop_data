defmodule ExopProps.ParamsGenerator do
  @moduledoc """
  Defines functions for generationg StreamData generator.
  """

  use ExUnitProperties

  import ExopProps.Utils

  alias ExopProps.{CommonFilters, CommonGenerators}

  @doc """
  Returns a StreamData generator for either an Exop operation or a contract.
  """
  @spec generate_for(module() | ExopProps.contract(), keyword()) :: StreamData.t()
  def generate_for(operation, opts) when is_atom(operation) do
    {:module, operation} = Code.ensure_compiled(operation)
    generate_for(operation.contract(), opts)
  end

  def generate_for(contract, opts) when is_list(contract) do
    optional_keys = optional_fields(contract)

    contract
    |> Enum.into(%{}, &generator_for_param(&1, opts))
    |> CommonGenerators.map(optional_keys)
  end

  def generate_for(_) do
    raise("""
    ExopProps: please provide either an operation's contract
    or operation's module to make a generator
    """)
  end

  @doc """
  Returns a StreamData generator for parameter's opts.
  """
  @spec resolve_opts(map(), map()) :: StreamData.t()
  def resolve_opts(%{equals: value}, _opts), do: resolve_exact(value)

  def resolve_opts(%{exactly: value}, _opts), do: resolve_exact(value)

  def resolve_opts(%{in: values}, _opts), do: resolve_in_list(values)

  def resolve_opts(%{format: regex}, _opts), do: resolve_format(regex)

  def resolve_opts(%{regex: regex}, _opts), do: resolve_format(regex)

  def resolve_opts(param_opts, opts) when is_map(param_opts) do
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

  defp generator_for_param(%{name: param_name, opts: param_opts} = contract_item, opts) do
    opts = Enum.into(opts, %{})
    generators = Map.get(opts, :generators, %{})
    param_generator = Map.get(generators, param_name)

    if is_generator?(param_generator) do
      {param_name, param_generator}
    else
      {param_name, build_generator(param_opts, opts)}
    end
  end

  defp build_generator(param_opts, opts) do
    param_opts
    |> Enum.into(%{})
    |> resolve_opts(opts)
  end

  defp resolve_exact(value), do: StreamData.constant(value)

  defp resolve_in_list(in_list) when is_list(in_list), do: StreamData.member_of(in_list)

  defp resolve_format(regex), do: Randex.stream(regex, mod: Randex.Generator.StreamData)
end
