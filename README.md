# Imager

Plug to apply image transformations on the fly based on the thumbor URL format.

## Development

### Run thumbor 

```sh
docker run --name thumbor -d -p 8888:80 minimalcompact/thumbor
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `imager` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:imager, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/imager>.

