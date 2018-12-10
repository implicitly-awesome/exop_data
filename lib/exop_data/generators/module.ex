defmodule ExopData.Generators.Module do
  @moduledoc """
  Implements ExopData generators behaviour for `module` parameter type.
  """

  @behaviour ExopData.Generator

  defmodule ExopData.FakeModule do
  end

  def generate(_opts \\ %{}, _props_opts \\ %{}) do
    StreamData.constant(ExopData.FakeModule)
  end
end
