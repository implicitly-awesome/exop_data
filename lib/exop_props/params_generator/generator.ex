defmodule ExopProps.ParamsGenerator.Generator do
  @moduledoc """
  Defines ExopProps generators behaviour.

  An ExopProps's generator should define `generate/1` function
  which takes a contract's parameter options with your property test options
  and returns StreamData generator made with respect to the options.
  """

  @callback generate(map(), map()) :: StreamData.t()
end
