defmodule ExopData.Generators.List do
  @moduledoc """
  Implements ExopData generators behaviour for `list` parameter type.
  """

  @behaviour ExopData.Generator

  alias ExopData.InnerResolver

  # this is the default maximum length of generated lists in cases where max length hasn't been provided
  @list_item_max_length 10

  alias ExopData

  def generate(opts \\ %{}, props_opts \\ %{})

  def generate(opts, props_opts) when is_list(opts) do
    opts |> Enum.into(%{}) |> generate(props_opts)
  end

  def generate(opts, props_opts) when is_list(props_opts) do
    generate(opts, Enum.into(props_opts, %{}))
  end

  def generate(%{inner: _} = opts, props_opts) do
    opts |> Map.put(:inner, InnerResolver.resolve_inner_opts(opts)) |> do_generate(props_opts)
  end

  def generate(opts, props_opts), do: do_generate(opts, props_opts)

  @spec do_generate(map(), map()) :: StreamData.t()
  defp do_generate(%{inner: _} = opts, props_opts) do
    StreamData.map(InnerResolver.generator(opts, props_opts), &Enum.into(&1, []))
  end

  defp do_generate(opts, %{generators: [%StreamData{} = generator]}) do
    StreamData.list_of(generator, length_opts(opts))
  end

  defp do_generate(opts, props_opts) do
    StreamData.list_of(list_item(opts, props_opts), length_opts(opts))

    # NOTE: alternative way to speed up inner list_item
    # generation, but you get lists of a fix length :(
    #
    # length =
    #   case length_opts(opts) do
    #     [length: length] -> length
    #     [min_length: min, max_length: max] -> Enum.random(min..max)
    #     [min_length: min] -> Enum.random(min..@list_item_max_length)
    #     [max_length: max] -> Enum.random(0..max)
    #   end

    # opts
    # |> list_item(props_opts)
    # |> List.duplicate(length)
    # |> StreamData.fixed_list()
  end

  @spec length_opts(map()) :: StreamData.t()
  defp length_opts(opts) when is_map(opts) do
    case Map.get(opts, :length) do
      %{is: exact} -> [length: exact]
      %{equals: exact} -> [length: exact]
      %{equal_to: exact} -> [length: exact]
      %{in: min..max} -> [min_length: min, max_length: max]
      %{min: min, max: max} -> [min_length: min, max_length: max]
      %{min: min} -> [min_length: min]
      %{max: max} -> [max_length: max]
      _ -> [min_length: 0, max_length: @list_item_max_length]
    end
  end

  defp length_opts(_opts), do: [min_length: 0, max_length: @list_item_max_length]

  @spec list_item(map(), map()) :: StreamData.t()
  defp list_item(opts, props_opts) do
    opts = opts |> Map.get(:list_item, %{}) |> Enum.into(%{})

    if Enum.any?(opts) do
      opts
      |> Map.put_new(:length, %{max: @list_item_max_length})
      |> ExopData.generator_for_opts(build_props_opts(props_opts))
    else
      StreamData.atom(:alphanumeric)
    end
  end

  defp build_props_opts(%{generators: [generators]} = props_opts) do
    Map.put(props_opts, :generators, generators)
  end

  defp build_props_opts(props_opts) do
    props_opts
  end
end
