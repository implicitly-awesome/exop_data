defmodule ExopProps.Utils do
  @moduledoc """
  Contains a bunch of common functions.
  """

  @doc """
  Checks whether a given value is StreamData generator.
  """
  @spec is_generator?(any()) :: boolean()
  def is_generator?(value) do
    value
    |> IEx.Info.info()
    |> List.keyfind("Data type", 0)
    |> case do
      {"Data type", "StreamData"} -> true
      _ -> false
    end
  end
end
