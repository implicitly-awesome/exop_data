defmodule ExopProps do
  alias ExopProps.ParamsGenerator

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      use ExUnitProperties
    end
  end

  def exop_props(contract_or_operation, opts \\ []) do
    ParamsGenerator.generate_for(contract_or_operation, opts)
  end
end
