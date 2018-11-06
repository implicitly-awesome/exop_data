defmodule ExopProps.ParamsGenerator.Atom do
  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(opts \\ []) do
    StreamData.atom(:alphanumeric)
  end
end
