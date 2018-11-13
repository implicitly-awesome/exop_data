defmodule ExopProps.ParamsGenerator.Term do
  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(_opts \\ %{}, _props_opts \\ %{}), do: StreamData.term()
end
