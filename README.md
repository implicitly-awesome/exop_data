# ExopData

[![Hex.pm](https://img.shields.io/hexpm/v/exop_data.svg)](https://hex.pm/packages/exop_data) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/exop_data/) [![Build Status](https://travis-ci.org/madeinussr/exop_data.svg?branch=master)](https://travis-ci.org/madeinussr/exop_data)

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
  - [required check](#required-check)
  - [allow_nil option](#allow_nil-option)
- [Complex data](#complex-data)
  - [list_item check](#list_item-check)
  - [inner check](#inner-check)
- [Exop docs](#exop-docs)
- [Generator options](#generator-options)
  - [Exact values](#exact-values)
  - [Custom generators](#custom-generators)

## Installation

```elixir
def deps do
  [{:exop_data, "~> 0.1.0"}]
end
```

## Why?

For either some projects or certain tasks property-based testing allows you to get your code
tested and proved for all available cases.
But it could be challenging and takes a lot of time to prepare proper data generators.
Provide correct generators for relatively complex data types is hard.
Such generators take a number of lines in your code, they are hard to read and maintain.
It could be repetitive work either.

ExopData offers you a convinient way to generate data based on Exop's operation (which is basically awesome) or
on a contract which is defined in delclarative, intuitive way.
ExopData easy to use and read. It is simply a joy to write property-based tests with ExopData.

Not interested in getting your code well-organized with Exop nor in property-based testing?
Well, consider data generating with ExopData at least.

## How it works

ExopData generates data with [StreamData](https://github.com/whatyouhide/stream_data) generators.
As an incoming argument ExopData expects an [Exop](https://github.com/madeinussr/exop) operation
module or (if you not ready yet to bring Exop into your project) a contract which describes
a set of parameters and their checks (validations).
Parameter checks definitions are based (actually they are the same) on Exop's checks.

Simply said, ExopData resolves an incoming contract and generates StreamData generators.
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

In order to generate data you need to prepare a contract, use `ExopData` module
and invoke `exop_data/2` function. Where the first argument is the contract and the second
are `Keyword` list of additional options.

```elixir
defmodule ExopPropsTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  @contract [
    %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
    %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
  ]

  property "Multiply" do
    check all %{a: a, b: b} <- ExopData.generate(@contract) do
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
  use ExUnitProperties

  property "Multiply" do
    check all %{a: a, b: b} = params <- ExopData.generate(MultiplyService) do
      {:ok, result} = MultiplyService.run(params)
      expected_result = a * b
      assert result == expected_result
    end
  end
end
```

In both cases the result will be the same: ExopData takes either the explicit contract or
the Operation module (and get it's contract under the hood) and generates a map, where keys are
params defined in the contract.

**NB**: `exop_data/2` imports `ExUnitProperties` so you don't need to include
`use ExUnitProperties` in your tests.

### Data generating

You can use ExopData not only in property tests, but in any place you need to generate data:

```elixir
contract = [
  %{name: :a, opts: [required: true, type: :integer, numericality: %{greater_than: 0}]},
  %{name: :b, opts: [required: true, type: :integer, numericality: %{greater_than: 10}]}
]

contract
|> ExopData.generate()
|> Enum.take(5)

[
  %{a: 3808, b: 3328},
  %{a: 7116, b: 8348},
  %{a: 3432, b: 7134},
  %{a: 7024, b: 7941},
  %{a: 7941, b: 6944}
]
```

Or with an Exop Operation defined:

```elixir
defmodule MultiplyService do
  use Exop.Operation

  parameter(:a, required: true, type: :integer, numericality: %{greater_than: 0})
  parameter(:b, required: true, type: :integer, numericality: %{greater_than: 10})

  def process(%{a: a, b: b} = _params), do: a * b
end

MultiplyService
|> ExopData.generate()
|> Enum.take(5)

[
  %{a: 401, b: 2889},
  %{a: 7786, b: 5894},
  %{a: 9187, b: 1863},
  %{a: 3537, b: 1285},
  %{a: 6124, b: 5521}
]
```

### `required` check

When it comes to data generating, by default, ExopData behaves like this:
if a parameter wasn't explicitly marked with a check `required: true` ExopData generates
that parameter occasionally (sometimes there is such parameter in generated data, sometimes not).
The parameter and it's value will always be presented in the resulting map only if it was explicitly
marked as required.

It allows us to generate fair data with all possible corner-cases for provided contract.

### `allow_nil` option

A parameter might have `allow_nil: true` option. In this case ExopData put some amount of `nil` values into resulting data. This amount is random and > 0.

## Complex data

ExopData allows you to generate pretty complex data structures by using `list_item` and `inner` parameter checks.

### `list_item` check

This parameter check defines a specification for all items in a list. It can contain all the possible checks as regular parameter might have.

```elixir
contract = [
  name: :param_list,
  opts: [type: :list, required: true, list_item: %{type: :string, required: true}]
]
```

That contract means that we expect `:param_list` parameter to be a required list which consist of a number of strings.
`required: true` within `list_item` check means we expect to get at least one item in this list.

### `inner` check

This check allow you to set expectations on a map parameter consist. Where keys are expected keys of the map parameter and values are their specifications.

```elixir
contract = [
  name: :param_map,
  opts: [type: :map, required: true, inner: %{
    a: [type: :integer, required: true],
    b: [type: :string],
    c: [type: :list, list_item: %{type: :integer, numericality: %{min: 10}}]
  }]
]
```

Worth to note: keys defined in `inner` check will be present in generated map in any case. Additionally there might be a number of keys which were not defined explicitly. This is because ExopData tries to generate different cases, for example: "What if this map contains not only expected set of keys?"

### As complex as you wish

Just kindly remind you: you can create a very complex contract (or describe it in Exop operation) by combining `inner` and `list_item` checks, make them nested etc.

```elixir
contract = [
  name: :param_complex_param,
  opts: [type: :map, required: true, inner: %{
    a: [type: :integer, numericality: %{in: 10..100}],
    b: [type: :list, length: %{min: 1}, list_item: %{
      type: :map, inner: %{
        c: [type: :list, required: true, list_item: %{
          type: :list, list_item: %{
            type: :map, inner: %{
              type: :string, length: %{is: 12}
            }
          }
        }]
      }
    }]
  }]
]
```

## Exop docs

We aren't going to provide a definitive guide for all possible checks and options which might be used in a contract definition, because all of them are described in Exop [docs](https://github.com/madeinussr/exop). Please, refer to it if needed.

## Generator options

### Exact values

### Custom generators

## LICENSE

    Copyright © 2018 Andrey Chernykh ( andrei.chernykh@gmail.com )

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.

