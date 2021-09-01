defmodule RRule.Util do
  @frequencies ~w(
		yearly
		monthly
		weekly
		daily
		hourly
		minutely
		secondly
	)a

  @frequency_map %{
    yearly: 0,
    monthly: 1,
    weekly: 2,
    daily: 3,
    hourly: 4,
    minutely: 5,
    secondly: 6
  }

  def compare_frequencies(a, a) when a in @frequencies, do: :eq

  def compare_frequencies(a, b) when a in @frequencies and b in @frequencies do
    if @frequency_map[a] < @frequency_map[b], do: :lt, else: :gt
  end

  def next_gte([], _), do: nil
  def next_gte([x | rest], search), do: if(x >= search, do: x, else: next_gte(rest, search))
end
