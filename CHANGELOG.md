## [0.1.3] - 2018.12.11

### Changes
- generator for `:module` value of the `type` check
- `allow_nil` has `false` value by default
- `map` generator without `length` opts provided produces [min: 0, max: 10] maps
- with no `type` check specified, but with `inner` a param is `:map` by default

## [0.1.2] - 2018.12.05

### Changes
- custom generators for `list_item` check
- all params in a contract are required by default and not required by explicitly specified `required: false`
- `struct` check can take a module atom name `MyStruct` not only `%MyStruct{}`
- structs generator has been refactored
- minor fixes and performance improvements

## [0.1.1] - 2018.11.15

### Changes
- `inner` check now works properly for `struct` check

## [0.1.0] - 2018.11.14

### Changes
- initial version 0.1.0 launched
- all the features description is available in README
- stay tuned, keep for updates

## [0.0.0] - 2018.11.06

### Changes
- init
