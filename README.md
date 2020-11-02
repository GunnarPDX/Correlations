[![MIT License](https://img.shields.io/apm/l/atomic-design-ui.svg?)](https://github.com/tterb/atomic-design-ui/blob/master/LICENSEs)
[![Hex.pm Version](http://img.shields.io/hexpm/v/correlations.svg?style=flat)](https://hex.pm/packages/correlations)

# Correlations

A financial correlations library for elixir, fully compatible with the elixir `Decimal` library.

![correlation matrix img](https://github.com/GunnarPDX/correlation-matrix-chart/blob/master/correlation-matrix.png?raw=true)

### Example frontend usage
https://github.com/GunnarPDX/Nice-Charts

## Installation

This package can be installed by adding `correlations` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:correlations, "~> 0.1.0"},
  ]
end
```

## Docs

#### HexDocs: [https://hexdocs.pm/correlations](https://hexdocs.pm/correlations/0.1.0/Correlations.html#functions)

## Functions

- `portfolio_correlations_picker(stocks, portfolio_size)`

- `portfolio_correlations_list(stocks, portfolio_size)`

- `correlation_matrix(stocks)`

- `json_correlation_matrix(stocks)`

- `correlation(x, y)`


## Usage
```elixir
iex> alias Correlations, as: C

iex> stocks = [
    aapl: [124.400002, 121.099998, 121.190002, 120.709999, 119.019997],
    nvda: [569.039978, 569.929993, 563.809998, 558.799988, 552.460022],
    tsla: [442.299988, 446.649994, 461.299988, 448.880005, 439.670013],
    amzn: [3442.929932, 3443.629883, 3363.709961, 3338.649902, 3272.709961]
  ]

iex> decimal_stocks = for {k, v} <- stocks, do: {k, decimalize(v)}

iex> C.portfolio_correlations_picker(decimal_stocks, 2)
{Decimal<0.104192125>, [:aapl, :tsla]}
```
