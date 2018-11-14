defmodule ExopData.CommonGenerators do
  @moduledoc """
  Functions to create and combine generators.
  """

  alias StreamData.LazyTree

  @rand_algorithm :exsp
  @unquoted_atom_characters [?a..?z, ?A..?Z, ?0..?9, ?_, ?@]

  @doc """
  Allow to generate maps with optional keys and generated values.

  `data_map` is a map of `fixed_key => data` pairs.
  `optional_keys` is a list of optional keys, which can be or cannot be in final result.

  ## Examples

      data = ExopData.CommonGenerators.map(
        %{
          integer: StreamData.integer(),
          binary: StreamData.binary(),
        },
        [:integer]
      )
      Enum.take(data, 3)
      #=> [%{binary: "a", integer: 1}, %{binary: "b"}, %{binary: "c", integer: 2}]
  """
  @spec map([StreamData.t()], [atom()]) :: StreamData.t()
  def map(data_map, optional_keys) do
    required_keys = Map.keys(data_map) -- optional_keys
    optional_keys_data = sublist(optional_keys)

    new(fn seed, size ->
      {seed1, seed2} = split_seed(seed)
      subkeys_tree = call(optional_keys_data, seed1, size)

      data_map
      |> Map.take(required_keys ++ subkeys_tree.root)
      |> StreamData.fixed_map()
      |> call(seed2, size)
      |> LazyTree.map(fn fixed_map ->
        LazyTree.map(subkeys_tree, fn keys ->
          Map.take(fixed_map, required_keys ++ keys)
        end)
      end)
      |> LazyTree.flatten()
    end)
  end

  @doc """
  Generates atoms.

  ## Options

    * `:length` - (integer or range) if an integer, the exact length the
      generated atoms should be; if a range, the range in which the length of
      the generated atoms should be. If provided, `:min_length` and
      `:max_length` are ignored.

    * `:min_length` - (integer) the minimum length of the generated atoms.

    * `:max_length` - (integer) the maximum length of the generated atoms.

  ## Examples

      Enum.take(ExopData.CommonGenerators.atom(), 3)
      #=> [:xF, :y, :B_]
  """
  @spec atom(keyword()) :: StreamData.t()
  def atom(options \\ []) do
    starting_char =
      StreamData.frequency([
        {4, StreamData.integer(?a..?z)},
        {2, StreamData.integer(?A..?Z)},
        {1, StreamData.constant(?_)}
      ])

    rest = StreamData.string(@unquoted_atom_characters, options)

    StreamData.map({starting_char, rest}, fn {first, rest} ->
      String.to_atom(<<first, String.slice(rest, 1..254)::binary>>)
    end)
  end

  @spec sublist([any()]) :: StreamData.t()
  defp sublist(list) do
    StreamData.map(
      StreamData.list_of(StreamData.boolean(), length: length(list)),
      fn indexes_to_keep ->
        for {elem, true} <- Enum.zip(list, indexes_to_keep), do: elem
      end
    )
  end

  @spec split_seed(integer()) :: {integer(), integer()}
  defp split_seed(seed) do
    {int, seed} = :rand.uniform_s(1_000_000_000, seed)
    new_seed = :rand.seed_s(@rand_algorithm, {int, 0, 0})
    {new_seed, seed}
  end

  @spec call(StreamData.t(), integer(), integer()) :: LazyTree.t()
  defp call(%StreamData{generator: generator}, seed, size) do
    %LazyTree{} = generator.(seed, size)
  end

  @spec new((any(), any() -> any())) :: StreamData.t()
  defp new(generator) when is_function(generator, 2) do
    %StreamData{generator: generator}
  end
end
