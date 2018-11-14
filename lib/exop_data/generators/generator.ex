defmodule ExopData.Generator do
  @moduledoc """
  Defines ExopData generators behaviour.

  An ExopData's generator should define `generate/1` function
  which takes a contract's parameter options with your property test options
  and returns StreamData generator made with respect to the options.
  """

  @callback generate(map(), map()) :: StreamData.t()
end
