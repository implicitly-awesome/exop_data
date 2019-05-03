locals_without_parens = [
  generate: 1,
  check_operation: 2,
  check_operation: 3
]

[
  inputs: ["mix.exs", "{config,lib}/**/*.{ex,exs}"],
  line_length: 100,
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
