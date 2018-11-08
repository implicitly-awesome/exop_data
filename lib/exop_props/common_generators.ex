defmodule ExopProps.CommonGenerators do
  @moduledoc """
  Functions to create and combine generators.
  """

  alias StreamData.LazyTree

  @rand_algorithm :exsp

  @spec map([StreamData.t()], [atom()], [atom()]) :: StreamData.t()
  def map(map_generator, required_keys, optional_keys) do
    optional_keys_data = sublist(optional_keys)

    new(fn seed, size ->
      {seed1, seed2} = split_seed(seed)
      subkeys_tree = call(optional_keys_data, seed1, size)

      map_generator
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

  defp sublist(list) do
    StreamData.map(
      StreamData.list_of(StreamData.boolean(), length: length(list)),
      fn indexes_to_keep ->
        for {elem, true} <- Enum.zip(list, indexes_to_keep), do: elem
      end
    )
  end

  defp split_seed(seed) do
    {int, seed} = :rand.uniform_s(1_000_000_000, seed)
    new_seed = :rand.seed_s(@rand_algorithm, {int, 0, 0})
    {new_seed, seed}
  end

  defp call(%StreamData{generator: generator}, seed, size) do
    %LazyTree{} = generator.(seed, size)
  end

  defp new(generator) when is_function(generator, 2) do
    %StreamData{generator: generator}
  end
end
