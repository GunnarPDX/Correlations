# Correlations

[WIP] A financial correlations library for elixir, fully compatible with the elixir `Decimal` library.

![correlation matrix img](https://github.com/GunnarPDX/correlation-matrix-chart/blob/master/corr-matrix.png?raw=true)

### Example frontend usage
[https://github.com/GunnarPDX/correlation-matrix-chart]

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `correlations` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:correlations, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/correlations](https://hexdocs.pm/correlations).


## Functions

- `portfolio_correlations_picker(stocks, portfolio_size)`

- `portfolio_correlations_list(stocks, portfolio_size)`

- `correlation_matrix(stocks)`

- `json_correlation_matrix(stocks)`

- `correlation(x, y)`


## Usage
```elixir
...
```

## To Dos
- add opts for standard/downside volatility
- add JSON method for graph data structure
- finish hex docs
