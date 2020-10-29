defmodule CorrelationsTest do
  use ExUnit.Case
  # TODO: fix hex docs formatting
  # doctest Correlations

  alias Correlations, as: C
  alias Decimal, as: D

  @ex_stocks [
    aapl: [124.400002, 121.099998, 121.190002, 120.709999, 119.019997],
    nvda: [569.039978, 569.929993, 563.809998, 558.799988, 552.460022],
    tsla: [442.299988, 446.649994, 461.299988, 448.880005, 439.670013],
    amzn: [3442.929932, 3443.629883, 3363.709961, 3338.649902, 3272.709961]
  ]

  @ex_corr_list [
    {0.809616345, [:aapl, :nvda]},
    {0.104192125, [:aapl, :tsla]},
    {0.674977695, [:aapl, :amzn]},
    {0.198672188, [:nvda, :tsla]},
    {0.867990065, [:amzn, :nvda]},
    {0.236184044, [:amzn, :tsla]}
  ]

  @ex_corr_matrix [
    [{:aapl, :amzn, 0.674977695}, {:aapl, :tsla, 0.104192125}, {:aapl, :nvda, 0.809616347}],
    [{:nvda, :amzn, 0.867990063}, {:nvda, :tsla, 0.198672188}],
    [{:tsla, :amzn, 0.236184044}]
  ]

  @ex_json_corr_matrix "[{\"color\":0.674977695,\"x\":1,\"xLabel\":\"aapl\",\"y\":1,\"yLabel\":\"amzn\"},{\"color\":0.104192125,\"x\":1,\"xLabel\":\"aapl\",\"y\":2,\"yLabel\":\"tsla\"},{\"color\":0.809616347,\"x\":1,\"xLabel\":\"aapl\",\"y\":3,\"yLabel\":\"nvda\"},{\"color\":0.867990063,\"x\":2,\"xLabel\":\"nvda\",\"y\":1,\"yLabel\":\"amzn\"},{\"color\":0.198672188,\"x\":2,\"xLabel\":\"nvda\",\"y\":2,\"yLabel\":\"tsla\"},{\"color\":0.236184044,\"x\":3,\"xLabel\":\"tsla\",\"y\":1,\"yLabel\":\"amzn\"}]"


  def decimalize(list),
      do: (for i <- list, do: D.from_float(i))


  test "lowest correlation portfolio pick" do
    D.Context.set(%D.Context{D.Context.get() | precision: 9})
    stocks_d = for {k, v} <- @ex_stocks, do: {k, decimalize(v)}

    res = C.portfolio_correlations_picker(stocks_d, 2)

    assert res == {D.from_float(0.104192125), [:aapl, :tsla]}
  end

  test "correlation list" do
    D.Context.set(%D.Context{D.Context.get() | precision: 9})
    stocks_d = for {k, v} <- @ex_stocks, do: {k, decimalize(v)}
    ex_corr_list = for {v, list} <- @ex_corr_list, do: {D.from_float(v), list}

    res = C.portfolio_correlations_list(stocks_d, 2)

    assert res == ex_corr_list
  end

  test "correlations matrix" do
    D.Context.set(%D.Context{D.Context.get() | precision: 9})
    stocks_d = for {k, v} <- @ex_stocks, do: {k, decimalize(v)}
    ex_corr_matrix = for l <- @ex_corr_matrix, do: (for {k1, k2, v} <- l, do: {k1, k2, D.from_float(v)})

    res = C.correlation_matrix(stocks_d)

    assert res == ex_corr_matrix
  end

  test "json correlations matrix" do
    D.Context.set(%D.Context{D.Context.get() | precision: 9})
    stocks_d = for {k, v} <- @ex_stocks, do: {k, decimalize(v)}

    {_, res} = C.json_correlation_matrix(stocks_d)

    assert res == @ex_json_corr_matrix
  end


end