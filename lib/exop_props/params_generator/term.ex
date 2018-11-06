defmodule ExopProps.ParamsGenerator.Term do
  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(_opts \\ []), do: StreamData.term()
end
