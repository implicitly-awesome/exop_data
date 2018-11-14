defmodule ExopData.Generators.Term do
  @behaviour ExopData.Generator

  def generate(_opts \\ %{}, _props_opts \\ %{}), do: StreamData.term()
end
