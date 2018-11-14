defmodule ExopData.Generators.Boolean do
  @moduledoc """
  Implements ExopData generators behaviour for `boolean` parameter type.
  """

  @behaviour ExopData.Generator

  def generate(_opts \\ %{}, _props_opts \\ %{}), do: StreamData.boolean()
end
