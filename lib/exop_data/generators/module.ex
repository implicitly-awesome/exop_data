defmodule ExopData.Generators.Module do
  @moduledoc """
  Implements ExopData generators behaviour for `module` parameter type.
  """

  alias ExopData.CommonGenerators

  @behaviour ExopData.Generator

  def generate(opts \\ %{}, _props_opts \\ %{}) do
    StreamData.atom(:alias)
  end
end
