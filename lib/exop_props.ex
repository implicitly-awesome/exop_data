defmodule ExopProps do
  @moduledoc """
  ExopProps utilize the power of two libs: Exop & StreamData to help you write property-based tests.
  ExopProps generates properties (essentially generates StreamData generators) based on Exop operation's
  contract.

  A contract is a list of maps `%{name: atom(), opts: keyword()}`, where each map represents
  a single parameter (`%{name: :param_a, opts: [type: :string, required: true, length: %{min: 1}]}`)

  For more information on Exop, operations, contracts and checks see https://github.com/madeinussr/exop
  """
  alias ExopProps.ParamsGenerator

  @type contract_item() :: %{name: atom(), opts: keyword()}
  @type contract() :: [contract_item()]

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      use ExUnitProperties
    end
  end

  @doc """
  Generates StreamData generators for a specific Exop operation or it's contract.
  """
  @spec exop_props(module() | contract(), keyword()) :: StreamData.t()
  def exop_props(contract_or_operation, opts \\ []) do
    ParamsGenerator.generate_for(contract_or_operation, opts)
  end
end
