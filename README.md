# ExopData

[![Hex.pm](https://img.shields.io/hexpm/v/exop_props.svg)](https://hex.pm/packages/exop_props) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/exop_props/) [![Build Status](https://travis-ci.org/madeinussr/exop_props.svg?branch=master)](https://travis-ci.org/madeinussr/exop_props)

The goal of this library is to help you to write property-based tests by utilizing the power of Exop and [StreamData](https://github.com/whatyouhide/stream_data)
If you already use [Exop](https://github.com/madeinussr/exop) it is super easy.
Even if you haven't had Exop in your project yet you can use ExopData - just need to provide
a desirable params description (contract) that conforms Exop operation's contract format (the list of `%{name: atom(), opts: keyword()}`).

Here is the [CHANGELOG](https://github.com/madeinussr/exop_data/blob/master/CHANGELOG.md)

## Table of Contents

- [Installation](#installation)
- [Why?](#why?)
- [How it works](#how-it-works)
  - [Contract](#contract)
  - [Property-based testing](#property-based-testing)
  - [Data generating](#data-generating)
  - [:required check](#:required-check)
- [Complex data](#complex-data)
  - [list_item](#list_item)
  - [inner](#inner)
- [Special cases](#special-cases)
  - [Exact values](#exact-values)
  - [Custom generators](#custom-generators)

## Installation

```elixir
def deps do
  [{:exop_props, "~> 0.1.0"}]
end
```

## Why?

For either some projects or certain tasks property-based testing allows you to get your code
tested and proved for all available cases.
But it could be challenging and takes a lot of time to prepare proper data generators.
Provide correct generators for relatively complex data types is hard.
Such generators take a number of lines in your code, they are hard to read and maintain.
It could be repetitive work either.

ExopProps offers you a convinient way to generate data based on Exop's operation (which is basically awesome) or
on a contract which is defined in delclarative, intuitive way.
ExopProps easy to use and read. It is simply a joy to write property-based tests with ExopProps.

Not interested in getting your code well-organized with Exop nor in property-based testing?
Well, consider data generating with ExopProps at least.

## How it works

ExopProps generates data with [StreamData](https://github.com/whatyouhide/stream_data) generators.
As an incoming argument ExopProps expects an [Exop](https://github.com/madeinussr/exop) operation
module or (if you not ready yet to bring Exop into your project) a contract which describes
a set of parameters and their checks (validations).
Parameter checks definitions are based (actually they are the same) on Exop's checks.

Simply said, ExopProps resolves an incoming contract and generates StreamData generators.
At the end you receive a map where keys are parameters names and their values as map values.

### Contract

As it said earlier, a contract is a way to describe your data expectations.
The easiest way is to define an [Exop](https://github.com/madeinussr/exop) Operation module.
By invoking `YourOperation.contract()` you might see this operation contract which was defined
with `parameter` macro.
Basically, a contract is a list of maps `[%{name: _param_name, opts: [_param_opts_checks]}]`.
So there is no strict need to have an Exop Operation module defined.

Although in order to describe a parameter checks and options you should use
Exop [checks](https://github.com/madeinussr/exop#parameter-checks).

A contract might look like this:

```elixir
[
  %{name: param_a, opts: [type: :atom]},
  %{name: param_b, opts: [type: :integer, required: true, numericality: %{min: 0, max: 10}]},
  # more params here
]
```

### Property-based testing

In order to generate data you need to prepare a contract, use `ExopProps` module
and invoke `exop_props/2` function. Where the first argument is the contract and the second
are `Keyword` list of additional options.

```elixir
defmodule ExopPropsTest do
  use ExUnit.Case, async: true
  use ExopProps

  @contract [
    %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
    %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
  ]

  property "Multiply" do
    check all %{a: a, b: b} <- exop_props(@contract) do
      result = MathService.multiply(a, b)
      expected_result = a * b
      assert result == expected_result
    end
  end
end
```

Or if you have an Exop Operation defined:

```elixir
defmodule MultiplyService do
  use Exop.Operation

  parameter(:a, required: true, type: :integer, numericality: %{greater_than: 0})
  parameter(:b, required: true, type: :integer, numericality: %{greater_than: 10})

  def process(%{a: a, b: b} = _params), do: a * b
end

defmodule ExopPropsTest do
  use ExUnit.Case, async: true
  use ExopProps

  property "Multiply" do
    check all %{a: a, b: b} = params <- exop_props(MultiplyService) do
      {:ok, result} = MultiplyService.run(params)
      expected_result = a * b
      assert result == expected_result
    end
  end
end
```

In both cases the result will be the same: ExopProps takes either the explicit contract or
the Operation module (and get it's contract under the hood) and generates a map, where keys are
params defined in the contract.

**NB**: `exop_props/2` imports `ExUnitProperties` so you don't need to include `use ExUnitProperties`
in your tests.

### Data generating

`exop_props/2` uses `ExUnitProperties` and invokes `ParamsGenerator.generate_for/2` function.

So you can use it not only in property tests, but in any place you need to generate data:

```elixir
alias ExopProps.ParamsGenerator

contract = [
  %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
  %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
]

generator = ParamsGenerator.generate_for(contract)

result = Enum.take(generator, 5)
```

### `:required` check

## Special cases

### Exact values

### Custom generators

## LICENSE

    Copyright © 2018 Andrey Chernykh ( andrei.chernykh@gmail.com )

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.

