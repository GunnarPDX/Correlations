defmodule Correlations do

  @moduledoc """
  Documentation for `Correlations`.
  """

  alias Decimal, as: D
  alias Enum, as: E
  alias List, as: L
  alias Map, as: M
  alias Atom, as: A


  @type coefficient :: non_neg_integer | :NaN | :inf
  @type exponent :: integer
  @type sign :: 1 | -1
  @type t :: %Decimal{sign: sign, coef: coefficient, exp: exponent}
  @type decimal :: t | integer | String.t()
  @type json :: String.t()


  @doc """
  ## Portfolio Correlations Picker
  Picks the optimal portfolio combination with lowest correlation coefficient

  ## Examples
  iex> stocks = [aapl: [#Decimal<124.400002>, #Decimal<121.099998>, ...], nvda: [#Decimal<552.460022>, ...], ... ]
  ...

  iex> size = 2
  2

  iex> portfolio_correlations_picker(stocks, portfolio_size)
  {#Decimal<0.104192125>, [:aapl, :tsla]}
  """
  @spec portfolio_correlations_picker(list({atom, list(decimal)}), integer) :: {decimal, list(atom)}

  def portfolio_correlations_picker(stocks, portfolio_size) do
    # find combinations
    # |> pick portfolio with lowest correlation
    portfolio_correlations_list(stocks, portfolio_size)
    |> E.reduce(nil, fn x, acc -> pick_lowest(x, acc) end)
  end



  @doc """
  ## Portfolio Correlations List
  Creates a list of portfolio combinations with correlation coefficients

  ## Examples
  iex> stocks = [aapl: [#Decimal<124.400002>, #Decimal<121.099998>, ...], nvda: [#Decimal<552.460022>, ...], ... ]
  ...

  iex> size = 2
  2

  iex> portfolio_correlations_list(stocks, portfolio_size)
  [
    {#Decimal<0.809616345>, [:aapl, :nvda]},
    {#Decimal<0.104192125>, [:aapl, :tsla]},
    {#Decimal<0.674977695>, [:aapl, :amzn]},
    {#Decimal<0.198672188>, [:nvda, :tsla]},
    {#Decimal<0.867990065>, [:amzn, :nvda]},
    {#Decimal<0.236184044>, [:amzn, :tsla]}
  ]
  """
  @spec portfolio_correlations_list(list({atom, list(decimal)}), integer) :: list({decimal, list(atom)})

  def portfolio_correlations_list(stocks, portfolio_size) do
    # make a list of symbols
    sym_list = for {k, _v} <- stocks, do: k
    # create a correlation matrix of all stock pair combos
    corr_matrix = correlation_matrix(stocks)
    # flatten correlation matrix
    corr_list = L.flatten(corr_matrix)
    # create stock combinations for all possible portfolios of desired size
    sym_combos = combinations(sym_list, portfolio_size)
    # create list of possible portfolios with avg overall correlation coefficient
    portfolio_correlations(sym_combos, corr_list)
  end



  @doc """
  ## Correlation Matrix
  Creates a correlation matrix from a list of products

  ## Examples
  iex> stocks = [aapl: [#Decimal<124.400002>, #Decimal<121.099998>, ...], nvda: [#Decimal<552.460022>, ...], ... ]
  ...

  iex> correlation_matrix(stocks)
  [
    [{:aapl, :nvda, #Decimal<0.809616347>},{:aapl, :tsla, #Decimal<0.104192125>},{:aapl, :amzn, #Decimal<0.674977695>}],
    [{:nvda, :tsla, #Decimal<0.198672188>}, {:nvda, :amzn, #Decimal<0.867990063>}],
    [{:tsla, :amzn, #Decimal<0.236184044>}],
  ]
  """
  @spec correlation_matrix(list({atom, list(decimal)})) :: list(list({atom, atom, decimal}))
  def correlation_matrix(stocks) do
    # get percent changes per tick
    # then generate corr matrix
    stocks
    |> get_percent_changes()
    |> correlation_matrix([])
  end

  # end when tail is empty
  defp correlation_matrix([_], acc) do
    E.reverse(acc)
  end

  defp correlation_matrix([head|tail], acc) do
    # find correlation coefficient pair combinations for head with remaining stocks
    res = correlation_coefs(head, tail, []) |> E.reverse() # reverse list to 'fix/prettify' data order
    # repeat for remaining stocks
    correlation_matrix(tail, [res|acc])
  end

  # shouldn't ever get reached
  defp correlation_matrix([], acc),
      do: E.reverse(acc)



  @doc """
  ## JSON Correlation Matrix
  returns matrix data in JSON format.
  Ex frontend usage: (Link)[https://github.com/GunnarPDX/correlation-matrix-chart]
  """
  ## json format ~> {x: 3, y: 1, color: 0.236184044, xLabel: 'tsla', yLabel: 'amzn'}
  @spec correlation_matrix(list({atom, list(decimal)})) :: json
  def json_correlation_matrix(stocks) do
    # create corr matrix data structure
    corr_matrix = correlation_matrix(stocks)
    # reformat matrix for frontend usage
    {_i, res_list} = json_matrix(corr_matrix)
    # flatten and convert to JSON
    res_list
    |> L.flatten()
    |> Jason.encode()
  end

  # reformat matrix to have x and y indicies
  defp json_matrix(corr_matrix) do
    E.reduce(corr_matrix, {1,[]}, fn(l, {index, acc}) ->

      {_, _, row} = E.reduce(l, {index, 1, []}, fn({sym1, sym2, corr_val}, {i1, i2, acc}) ->
        # convert corr_val decimal to float and tickers to strings for frontend
        cell = %{x: i1, y: i2, color: D.to_float(corr_val), xLabel: A.to_string(sym1), yLabel: A.to_string(sym2)}
        # iterate col
        {i1, i2 + 1, acc ++ [cell]}
      end)
      # iterate row
      {index + 1, [acc|row]}
    end)
  end



  @doc false
  defp get_percent_changes(stocks),
       do: for {k, v} <- stocks, do: {k, changes(v)}

  defp changes([head|tail]),
       do: changes(tail, head, [])

  defp changes([head|tail], prev, acc) do
    # find percent change
    per_change = D.mult(D.div(D.sub(head, prev), prev), 100)
    changes(tail, head, [per_change|acc])
  end

  defp changes([], _, acc),
       do: E.reverse(acc)



  @doc false
  # TODO
  defp _get_downside_changes(stocks),
       do: for {k, v} <- stocks, do: {k, _downside_changes(v)}

  defp _downside_changes([head|tail]),
       do: _downside_changes(tail, head, [])

  defp _downside_changes([head|tail], prev, acc) do
    # find percent change
    per_change = D.mult(D.div(D.sub(head, prev), prev), 100)
    # ignore positive changes
    cond do
      per_change > 0 -> _downside_changes(tail, head, [D.new(0)|acc])
      :else -> _downside_changes(tail, head, [per_change|acc])
    end
  end

  defp _downside_changes([], _, acc),
       do: E.reverse(acc)



  @doc false
  defp correlation_coefs({symbol, quotes} = stock ,[{curr_symbol, curr_quotes} = _head|tail], acc) do
    # find correlation coefficients for stock with each remaining stock
    corr_coef = correlation(quotes, curr_quotes) |> D.abs() # TODO: add opts for pos/neg corr coef
    # package result as tuple with stocks names
    res = {symbol, curr_symbol, corr_coef}
    # repeat for remaining stocks
    correlation_coefs(stock, tail, [res|acc])
  end

  defp correlation_coefs(_, [], acc),
       do: E.reverse(acc)



  @doc """
  ## Correlation
  Finds the correlation coefficient between two lists of decimals

  ## Examples
  iex> list1 = [#Decimal<124.400002>, #Decimal<121.099998>, ...]
  ...

  iex> list2 = [#Decimal<569.039978>, #Decimal<569.929993>, ...]
  ...

  iex> correlation(list1, list2)
  #Decimal<0.809616345>

  """
  @spec correlation(list(decimal), list(decimal)) :: decimal
  def correlation(x, y) when length(x) == length(y) do
    # Pearson’s correlation coefficient formula
    # (insensitive to argument order)
    avg_x = mean(x)
    avg_y = mean(y)
    n = x
        |> Enum.zip(y)
        |> Enum.map(fn {xi, yi} -> D.mult(D.sub(xi, avg_x), D.sub(yi, avg_y)) end)
        |> E.reduce(fn x, acc -> D.add(x, acc) end)
    # |> E.sum()
    dx = denominate(x, avg_x)
    dy = denominate(y, avg_y)
    D.div(n, D.sqrt(D.mult(dx, dy)))
  end

  defp denominate(list, avg) do
    list
    |> Enum.map(fn i -> D.mult(D.sub(i, avg), D.sub(i, avg)) end)
    |> E.reduce(fn x, acc -> D.add(x, acc) end)
    # |> E.sum()
  end



  @doc false
  # calc mean avg
  defp mean(list) when is_list(list),
       do: mean(list, 0, 0)

  defp mean([], 0, 0),
       do: nil

  defp mean([], t, l),
       do: D.div(t, l)

  defp mean([x | xs], t, l),
       do: mean(xs, D.add(t, x), D.add(l, 1))



  @doc false
  # create stock combos for possible portfolios
  defp combinations(enum, k) do
    List.last(create_combos(enum, k))
    |> Enum.uniq
  end

  defp create_combos(enum, k) do
    combos_by_length = [[[]]|List.duplicate([], k)]
    list = Enum.to_list(enum)
    List.foldr list, combos_by_length, fn x, next ->
      sub = :lists.droplast(next)
      step = [[]|(for l <- sub, do: (for s <- l, do: [x|s]))]
      :lists.zipwith(&:lists.append/2, step, next)
    end
  end



  @doc false
  defp portfolio_correlations(sym_combos, corr_list) do
    # loop through symbol combos and find correlation coefficient averages
    # |> filter for fully linked nodes
    # |> return avg coefficient for portfolio
    for x <- sym_combos do
      corr_list
      |> E.filter(fn {s1, s2, _val} -> E.member?(x, s1) and E.member?(x, s2) end)
      |> average_combo_corr_coef()
    end
  end

  defp average_combo_corr_coef(combo) do
    # create map of stocks with lists of coefficients
    coef_map = E.reduce(combo, %{}, fn
      x, acc ->
        {sym1, sym2, coef} = x
        M.merge(acc, %{sym1 => [coef]}, fn _k, v1, v2 -> v1 ++ v2 end)
        |> M.merge(%{sym2 => [coef]}, fn _k, v1, v2 -> v1 ++ v2 end)
    end)

    # average coefficient lists and then average whole portfolio
    coef_avg = for {_sym, list} <- coef_map do mean(list) end |> mean()
    # reform symbol list for portfolio
    sym_list = for {sym, _list} <- coef_map do sym end
    # return portfolio tuple with correlation coefficient and stocks
    {coef_avg, sym_list}
  end



  @doc false
  # pick portfolio with lowest correlation coefficient
  defp pick_lowest(x, nil),
       do: x

  defp pick_lowest({k, _v} = x, {acc_k, _acc_v} = acc) do
    cond do
      D.lt?(k, acc_k) -> x
      :else -> acc
    end
  end



end