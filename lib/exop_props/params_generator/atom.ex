defmodule ExopProps.ParamsGenerator.Atom do
  @moduledoc """
  Implements ExopProps generators behaviour for `atom` parameter type.
  """

  @behaviour ExopProps.ParamsGenerator.Generator

  def generate(opts \\ []) do
    # TODO: implement :alias option
    StreamData.atom(:alphanumeric)
  end
end
