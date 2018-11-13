defmodule ExopProps.ParamsGenerator.Tuple do
  @moduledoc """
  Implements ExopProps generators behaviour for `tuple` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(_opts \\ %{}, _props_opts \\ %{}) do
    StreamData.tuple({StreamData.term(), StreamData.term()})
  end
end
