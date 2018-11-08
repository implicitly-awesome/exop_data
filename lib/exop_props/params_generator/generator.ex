defmodule ExopProps.ParamsGenerator.Generator do
  @moduledoc """
  Defines ExopProps generators behaviour.

  An ExopProps's generator should define `generate/1` function
  which takes a contract's parameter options (Keyword.t())
  and returns StreamData generator made with respect to the options.
  """

  @callback generate(map()) :: StreamData.t()
end
