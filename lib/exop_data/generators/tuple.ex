defmodule ExopData.Generators.Tuple do
  @moduledoc """
  Implements ExopData generators behaviour for `tuple` parameter type.
  """

  @behaviour ExopData.Generator

  def generate(_opts \\ %{}, _props_opts \\ %{}) do
    StreamData.tuple({StreamData.term(), StreamData.term()})
  end
end
