# Used by "mix format"
[
  import_deps: [:plug],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [assert_similar: 4]
]
