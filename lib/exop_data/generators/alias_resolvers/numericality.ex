defmodule ExopData.Generators.AliasResolvers.Numericality do
  @moduledoc """
  Resolves `:numericality` check option aliases.
  """

  @spec resolve_aliases(map()) :: map()
  def resolve_aliases(%{gt: gt} = numericality_opts) do
    numericality_opts
    |> Map.delete(:gt)
    |> Map.put(:greater_than, gt)
    |> resolve_aliases()
  end

  def resolve_aliases(%{gte: gte} = numericality_opts) do
    numericality_opts
    |> Map.delete(:gte)
    |> Map.put(:greater_than_or_equal_to, gte)
    |> resolve_aliases()
  end

  def resolve_aliases(%{min: min} = numericality_opts) do
    numericality_opts
    |> Map.delete(:min)
    |> Map.put(:greater_than_or_equal_to, min)
    |> resolve_aliases()
  end

  def resolve_aliases(%{lt: lt} = numericality_opts) do
    numericality_opts
    |> Map.delete(:lt)
    |> Map.put(:less_than, lt)
    |> resolve_aliases()
  end

  def resolve_aliases(%{lte: lte} = numericality_opts) do
    numericality_opts
    |> Map.delete(:lte)
    |> Map.put(:less_than_or_equal_to, lte)
    |> resolve_aliases()
  end

  def resolve_aliases(%{max: max} = numericality_opts) do
    numericality_opts
    |> Map.delete(:max)
    |> Map.put(:less_than_or_equal_to, max)
    |> resolve_aliases()
  end

  def resolve_aliases(numericality_opts), do: numericality_opts
end
