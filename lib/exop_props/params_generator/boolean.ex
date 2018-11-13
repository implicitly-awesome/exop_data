defmodule ExopProps.ParamsGenerator.Boolean do
  @moduledoc """
  Implements ExopProps generators behaviour for `boolean` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(_opts \\ %{}, _props_opts \\ %{}), do: StreamData.boolean()
end
