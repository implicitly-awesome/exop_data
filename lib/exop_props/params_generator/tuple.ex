defmodule ExopProps.ParamsGenerator.Tuple do
  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(_opts \\ []) do
    StreamData.tuple({StreamData.term(), StreamData.term()})
  end
end
