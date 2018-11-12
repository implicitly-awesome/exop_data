defmodule ExopProps.Utils do
  @moduledoc """
  Contains a bunch of common utils.
  """

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
