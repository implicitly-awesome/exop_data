defmodule ExopProps do
  alias ExopProps.ParamsGenerator

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      use ExUnitProperties
    end
  end

  # TODO: opts should allow to (force) define a parameter value
  defmacro params(operation, opts \\ []) do
    {operation, []} = Code.eval_quoted(operation, [], __CALLER__)
    {_opts, []} = Code.eval_quoted(opts, [], __CALLER__)

    %{params: params, clauses: clauses} = ParamsGenerator.generate_for(operation)

    {
      :gen,
      [context: nil],
      [
        {:all, [], clauses},
        [do: {:%{}, [], Enum.map(params, &{&1, {&1, [], nil}})}]
      ]
    }
  end
end
