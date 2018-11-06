defmodule ExopProps.ParamsGenerator.Boolean do
  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(_opts \\ []), do: StreamData.boolean()
end
