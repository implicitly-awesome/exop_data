# ExopData

[![Hex.pm](https://img.shields.io/hexpm/v/exop_data.svg)](https://hex.pm/packages/exop_data) [![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](http://hexdocs.pm/exop_data/) [![Build Status](https://travis-ci.org/madeinussr/exop_data.svg?branch=master)](https://travis-ci.org/madeinussr/exop_data)

The goal of this library is to help you to write property-based tests by utilizing the power of [Exop](https://github.com/madeinussr/exop) and [StreamData](https://github.com/whatyouhide/stream_data).
If you already use [Exop](https://github.com/madeinussr/exop) it is super easy.
Even if you haven't had Exop in your project yet you can use ExopData - just need to provide
a desirable params description (contract) that conforms Exop operation's contract format (the list of `%{name: atom(), opts: keyword()}`).
Not interested in property-based testing, but need to generate data? ExopData will help you with this as well.

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
  - [As complex as you wish](#as-complex-as-you-wish)
- [Exop operations](#exop-operations)
- [Exop docs](#exop-docs)
- [Generator options](#generator-options)
  - [Custom generators](#custom-generators)
  - [Exact values](#exact-values)
  - [~g sigil](#~g-sigil)
- [Limitations](#limitations)
  - [struct: %MyStruct{}](#struct-mystruct)
  - [type: :struct](#type-struct)
  - [Format (regex)](#format-regex)
  - [Func](#func)
- [Configuration](#configuration)

## Installation

```elixir
def deps do
  [{:exop_data, "~> 0.1.7"}]
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

## How does it work?

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
  %{name: param_a, opts: [type: :atom, required: false]},
  %{name: param_b, opts: [type: :integer, numericality: %{min: 0, max: 10}]},
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
    %{name: :a, opts: [type: :integer, numericality: %{greater_than: 0}]},
    %{name: :b, opts: [type: :integer, numericality: %{greater_than: 10}]}
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

  parameter(:a, type: :integer, numericality: %{greater_than: 0})
  parameter(:b, type: :integer, numericality: %{greater_than: 10})

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

### Data generating

You can use ExopData not only in property tests, but in any place you need to generate data:

```elixir
contract = [
  %{name: :a, opts: [type: :integer, numericality: %{greater_than: 0}]},
  %{name: :b, opts: [type: :integer, numericality: %{greater_than: 10}]}
]

#iex> contract |> ExopData.generate() |> Enum.take(5)
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

  parameter(:a, type: :integer, numericality: %{greater_than: 0})
  parameter(:b, type: :integer, numericality: %{greater_than: 10})

  def process(%{a: a, b: b} = _params), do: a * b
end

#iex> MultiplyService |> ExopData.generate() |> Enum.take(5)
[
  %{a: 401, b: 2889},
  %{a: 7786, b: 5894},
  %{a: 9187, b: 1863},
  %{a: 3537, b: 1285},
  %{a: 6124, b: 5521}
]
```

### `required` check

By default a parameter and it's value will always be presented in the resulting map. If a parameter explicitly marked with the check `required: false` ExopData generates that parameter occasionally (sometimes there is such parameter in generated data, sometimes not). It allows us to generate fair data with all possible corner-cases for provided contract.

### `allow_nil` option

A parameter might have `allow_nil: true` option. In this case ExopData put some amount of `nil` values into resulting data. This amount is random and > 0.

## Complex data

ExopData allows you to generate pretty complex data structures by using `list_item` and `inner` parameter checks.

### `list_item` check

This parameter check defines a specification for all items in a list. It can contain all the possible checks as regular parameter might have.

```elixir
contract = [
  name: :param_list,
  opts: [type: :list, list_item: %{type: :string}, length: %{min: 1}]
]
```

That contract means that we expect `:param_list` parameter to be a required list which consist of a number of strings.
`length: %{min: 1}` check means we expect to get at least one item in this list.

### `inner` check

This check allow you to set expectations on a map parameter consist. Where keys are expected keys of the map parameter and values are their specifications.

```elixir
contract = [
  name: :param_map,
  opts: [type: :map, inner: %{
    a: [type: :integer],
    b: [type: :string, required: false],
    c: [type: :list, list_item: %{type: :integer, numericality: %{min: 10}}]
  }]
]
```

Worth to note: keys defined in `inner` check will be present in generated map in any case. Additionally there might be a number of keys which were not defined explicitly. This is because ExopData tries to generate different cases, for example: "What if this map contains not only expected set of keys?"

### As complex as you wish

Just kindly remind you: you can create a very complex contract (or describe it in Exop operation) by combining `inner` and `list_item` checks, make them nested etc.

Something crazy like this:

```elixir
contract = [
  %{
    name: :complex_param,
    opts: [
      type: :map, inner: %{
        a: [type: :integer, numericality: %{in: 10..100}],
        b: [type: :list, length: %{min: 1}, list_item: %{
          type: :map, inner: %{
            c: [type: :list, list_item: %{
              type: :list, list_item: %{
                type: :map, inner: %{
                  d: [type: :string, length: %{is: 12}]
                }
              }
            }]
          }
        }]
      }
    ]
  }
]
```

## Exop operations

As we mentioned earlier, you can generate data by providing Exop.Operation module.

```elixir
defmodule MultiplyService do
  use Exop.Operation

  parameter(:a, type: :integer, numericality: %{greater_than: 0})
  parameter(:b, type: :integer, numericality: %{greater_than: 10})

  def process(%{a: a, b: b} = _params), do: a * b
end

#iex> MultiplyService |> ExopData.generate() |> Enum.take(5)
[
  %{a: 401, b: 2889},
  %{a: 7786, b: 5894},
  %{a: 9187, b: 1863},
  %{a: 3537, b: 1285},
  %{a: 6124, b: 5521}
]
```

So this helps to write tests a lot:

```elixir
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

It has been decided to make this even cleaner with `check_operation` macro:

```elixir
defmodule ExopPropsTest do
  use ExUnit.Case, async: true
  use ExopData

  property "Multiply" do
    check_operation(MultiplyService, fn params ->
      assert is_intger(params.a)

      # you simply should define expected result of an Operation
      # under the hood this is compared with MultiplyService.run(params) result
      {:ok, params.a * params.b}
    end)
  end
end
```

And of course `check_operation` still can receive custom generators:

```elixir
check_operation(MultiplyService, [generators: your_generators], fn params ->
  # your checks here
end)
```

## Exop docs

We aren't going to provide a definitive guide for all possible checks and options which might be used in a contract definition, because all of them are described in Exop [docs](https://github.com/madeinussr/exop). Please, refer to it if needed.

## Generator options

### Custom generators

Sometimes you need to generate complex data or use specific values for your parameters. You can achieve it with custom generators. Take a look at the example:

```elixir
contract = [
  %{name: :email, opts: [type: :string, format: ~r/@/]}
]
```

Let's say we want to use specific generator for this parameter:

```elixir
import ExUnitProperties
import StreamData

domains = [
  "gmail.com",
  "hotmail.com",
  "yahoo.com",
]

email_generator =
  gen all name <- string(:alphanumeric),
          name != "",
          domain <- member_of(domains) do
    name <> "@" <> domain
  end
```

You just need to pass it to `generate` function with path to concrete parameter:

```elixir
#iex> contract |> ExopData.generate(generators: %{email: email_generator}) |> Enum.take(2)
[%{email: "efsT6Px@hotmail.com"}, %{email: "swEowmk7mW0VmkJDF@yahoo.com"}]
```

The cool thing is that it is also possible to pass specific generators for `inner` and `list_item` parameters and they can be nested as deep as you want:

```elixir
contract = [
  %{
    name: :users,
    opts: [
      type: :list, list_item: [
        type: :map, inner: %{
          email: [type: :string, format: ~r/@/]
        }
      ]
    ]
  }
]

#iex> contract |> ExopData.generate(generators: %{users: [%{email: email_generator}]}) |> Enum.take(2)
[
  %{users: [%{email: "efsT6Px@hotmail.com"}]},
  %{users: [%{email: "swEowmk7mW0VmkJDF@yahoo.com"}]}
]
```

In the example above `generators: %{users: [%{email: email_generator}]}` means that there is a custom generator for `users` param list item. And since it is a map, we've provided the generator for the particular `email` field.

So you can use any `StreamData` generators: default or custom.

### Exact values

If you need exact value for your parameter just provide a specific value (implicit generator) or `StreamData.constant/1` as custom generator.

For example:

```elixir
contract = [%{name: :a, opts: [type: :atom]}]

check all params <- generate(contract, generators: %{a: :your_value}) do
  assert %{a: :your_value} == params
end
```

```elixir
contract = [
  %{
    name: :a,
    opts: [type: :list, inner: %{b: [type: :atom]}]
  }
]

check all %{a: a} <- generate(contract, generators: %{a: [b: :your_value]}) do
  assert :your_value = a[:b]
end
```

_Under the hood an exact value is wrapped with `StreamData.constant/1` and returns a generator, so you can use `StreamData.constant/1` itself if you like._

### ~g sigil

The best way to apply custom generators or certain values is `~g` sigil.
_In order to use the sigil you need to add `use ExopData` into your tests module._

```elixir
use ExopData

# let's say you have a contract (or an Operation with such contract)
contract = [
  %{
    name: :a,
    opts: [inner: %{
      b: [inner: %{
        c: [type: :integer],
        e: [inner: %{
          f: [type: :atom]
        }]
      }],
      d: [type: :string]
    }]
  }
]

# and you want :f within (a[:b][:f]) to have a specific value
# you can define it in your custom generators structure:
custom_generators = ~g[
  a: %{
    b: %{
      e: %{
        f: :my_atom
      }
    }
  }
]

# or you want :d (a[:d]) to be generated by `StreamData.binary/1` generator:
custom_generators = ~g[
  a: %{
    d: StreamData.binary()
  }
]

# or may be you want to combine:
custom_generators = ~g[
  a: %{
    b: %{
      e: %{
        f: StreamData.atom(:alias)
      }
    },
    d: "qwerty"
  }
]

# then just pass custom generators to `ExopData.generate/2`:
check all %{a: a} <- generate(contract, generators: custom_generators) do
  # your assertions here
end
```

It is worth to notice:
- an empty map is treated as certain value
- all fields that were ommited in custom generators definition will be generated according to a contract

```elixir
contract = [
  %{
    name: :a,
    opts: [inner: %{
      b: [inner: %{
        c: [type: :integer],
        e: [inner: %{
          f: [type: :atom]
        }]
      }],
      d: [type: :string]
    }]
  }
]

custom_generators = ~g[
  a: %{}
]
#iex> ExopData.generate(contract, generators: custom_generators) |> Enum.take(2)
%{}
%{}

custom_generators = ~g[
  a: %{b: %{}}
]
#iex> ExopData.generate(contract, generators: custom_generators) |> Enum.take(2)
%{b: %{}}
%{b: %{}}

custom_generators = ~g[
  a: %{b: %{c: 123}}
]
#iex> ExopData.generate(contract, generators: custom_generators) |> Enum.take(1)
%{
  b: %{
    c: 123,
    e: %{
      f: :_vk5zBT_2suYbECXGrAxsb2ywyzThN5ql_460eyjNPsmwHEAg16CAf8ceDx7RGGJ_GjJehlieb3z
    }
  },
  d: "n9e"
}

custom_generators = ~g[
  a: %{d: "qwe"}
]
#iex> ExopData.generate(contract, generators: custom_generators) |> Enum.take(2)
%{b: %{c: -57, e: %{f: :X@VcshCgqnIthJ@wopGBU@F3Pc5FBxCKFfbKg}}, d: "qwe"}
%{b: %{c: 75, e: %{f: :wAeV3hG}}, d: "qwe"}
```

## Limitations

### struct: MyStruct | %MyStruct{}

Parameter with `struct` validation is populated with struct of random data. Imagine we have such contract:

```elixir
contract = [%{name: :struct_param, opts: [struct: MyStruct]}]
```

ExopData might generate:

```elixir
#iex> contract |> ExopData.generate() |> Enum.take(3)
[
  %{struct_param: %MyStruct{a: 1}},
  %{struct_param: %MyStruct{a: "0"}},
  %{struct_param: %MyStruct{a: ""}}
]
```

You can use [exact values](#exact-values) or [custom generators](#custom-generators) options to build more specific values.

_Sad but true: currently `struct` generator is not as efficient as `map` generator.
So if you experience performace issues during your property tests, please consider `type: :map` in your contract or provide more specific checks for your struct (with `inner` for example)._

### type: :struct

This check usually means "this parameter should be some struct and I don't care which exactly". Even if it is possible to generate some maps with fake `__struct__` key, we think that it is not the correct way to do so.
You can use [exact values](#exact-values), [custom generators](#custom-generators), [struct: %MyStruct{}](#struct-mystruct) or `type: :map`.

### Format (regex)

You can describe your parameters with format based on regular expressions:

```elixir
contract = [
  %{
    name: :rsa_fingerprint,
    opts: [format: ~r/^(ssh-rsa) ([0-9]{3,4}) ([0-9a-f]{2}:){15}[0-9a-f]{2}$/]
  }
]
```

Thanks to the [Randex](https://github.com/ananthakumaran/randex) we can generate data for such parameters as well:

```elixir
#iex> contract |> ExopData.generate() |> Enum.take(3)
[
  %{
    rsa_fingerprint: "ssh-rsa 569 60:1b:bd:78:cc:8d:09:b8:ce:ee:0c:45:72:7c:0d:e8"
  },
  %{
    rsa_fingerprint: "ssh-rsa 737 0a:16:df:0a:5d:3b:8b:21:6d:bf:33:bf:06:44:5f:b7"
  },
  %{
    rsa_fingerprint: "ssh-rsa 3019 fc:ca:fe:a8:7c:63:c9:e5:46:0e:a3:e4:be:74:0f:35"
  }
]
```

At the moment [Randex](https://github.com/ananthakumaran/randex) doesn't support some regular expressions, check docs for this library to know more. You can use [exact values](#exact-values) or [custom generators](#custom-generators) options to build more specific values.

_Sad but true: generating data based on a regex is time-consuming process. `format` check in your operation contract is good for validation, decent enough for just data generating and totally unefficient for property-based tests (as there are a lot of runs, therefore N\*t where N is runs amount and t is time needed to generate your data)._

### Func

ExopData doesn't support data generation for parameters with `func` validations, use [exact values](#exact-values) or [custom generators](#custom-generators) options to build values for such parameters.

## Configuration

In order to speedup your props test during developent you can adjust `StreamData`'s `max_run` configuration options, like this:

`config :stream_data, max_runs: (if Mix.env() == :test, do: 50, else: 500)`

`StreamData` config options (and their defaults):

```elixir
max_runs: 100,
max_run_time: :infinity,
max_shrinking_steps: 100
```

## Maintainers

Andrey Chernykh ([madeinussr](https://github.com/madeinussr))

Aleksandr Fomin ([llxff](https://github.com/llxff))

## LICENSE

    Copyright © 2019 Andrey Chernykh ( andrei.chernykh@gmail.com )

    This work is free. You can redistribute it and/or modify it under the
    terms of the MIT License. See the LICENSE file for more details.
