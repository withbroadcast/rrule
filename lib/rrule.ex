defmodule RRule do
  alias RRule.{Rule, RuleSet, Util}

  def next_occurrence(ruleset, datetime) do
    RuleSet.next_occurrence(ruleset, datetime)
  end

  def next_occurrences(ruleset, datetime, count) do
    RuleSet.next_occurrences(ruleset, datetime, count)
  end

  ## Stuff

  @type datetime :: DateTime.t() | NaiveDateTime.t() | Date.t()

  def all(rule, opts \\ [])

  def all(rule, opts) when is_binary(rule) do
    rule
    |> RRule.Parser.ICal.parse()
    |> next(opts)
  end

  def all(%Rule{} = rule, opts) do
    expanded = expand_rule(rule, opts)
    first = generate_first(expanded, opts)
    Stream.iterate(first, fn dt -> generate_next(dt, expanded, opts) end)
  end

  defp generate_first(%Rule{freq: :weekly} = rule, _opts) do
    weekday = Timex.day_to_num(hd(rule.byweekday))
    start_weekday = Timex.weekday(rule.dtstart)
    diff = weekday - start_weekday

    if diff >= 0 do
      shift(rule.dtstart, :days, diff)
    else
      # TODO: use new algo
      # 7 - diff + 1
      rule.dtstart
      |> Timex.beginning_of_week()
      |> shift(:weeks, 1)
      |> shift(:days, weekday + diff)
      |> set_time(rule)
    end
  end

  defp generate_first(%Rule{freq: :monthly} = rule, opts) do
    generate_first_monthly(rule, opts)
  end

  defp generate_first(rule, _opts), do: rule.dtstart

  defp generate_first_monthly(%Rule{bymonthday: [day]} = rule, _opts) when day < 0 do
    start =
      rule.dtstart
      |> Timex.end_of_month()
      |> shift(:days, day + 1)
      |> set_time(rule)

    if Timex.compare(rule.dtstart, start) < 1 do
      start
    else
      next_for_frequency(rule, start)
    end
  end

  defp generate_first_monthly(%Rule{bymonthday: [day]} = rule, _opts) when day > 0 do
    if rule.dtstart.day > day do
      # advance month
      rule.dtstart
      |> Timex.beginning_of_month()
      |> shift(:months, 1)
      |> shift(:days, day)
      |> set_time(rule)
    else
      # go to day
      %{rule.dtstart | day: day}
      |> set_time(rule)
    end
  end

  defp generate_first_monthly(%Rule{bysetpos: [setpos], byweekday: [day]} = rule, _opts) do
    rule.dtstart
    |> shift_to_nth_weekday(day, setpos)
    |> set_time(rule)
  end

  defp generate_first_monthly(rule, _opts) do
    rule.dtstart
  end

  defp generate_next(dt, rule, opts) do
    rule
    |> expand_rule(opts)
    |> next_for_frequency(dt)
    |> filter_by_until(rule)
  end

  defp shift_to_nth_weekday(dt, weekday, n) when n < 0 do
    dt
    |> Timex.end_of_month()
    |> back_to_weekday(weekday)
  end

  defp shift_to_nth_weekday(dt, weekday, n) do
    dt
    |> Timex.beginning_of_month()
    |> advance_to_weekday(weekday)
    |> shift(:days, 7 * (n - 1))
  end

  defp advance_to_weekday(dt, byweekday) when is_atom(byweekday) do
    weekday = Timex.day_to_num(byweekday)
    start_weekday = Timex.weekday(dt)
    diff = weekday - start_weekday

    if diff >= 0 do
      shift(dt, :days, diff)
    else
      shift(dt, :days, 7 + diff)
    end
  end

  defp back_to_weekday(dt, byweekday) when is_atom(byweekday) do
    weekday = Timex.day_to_num(byweekday)
    start_weekday = Timex.weekday(dt)
    diff = weekday - start_weekday

    if diff < 0 do
      shift(dt, :days, diff)
    else
      shift(dt, :days, -1 * (7 - diff))
    end
  end

  defp next_after(rule, start, opts) do
    rule
    |> all(opts)
    |> Enum.find(fn dt ->
      Timex.compare(dt, start) == 1
    end)
  end

  @type next_option :: {:start, datetime()}
  @type next_options :: [next_option()]

  @doc """
  Generates the next occurrence of the given rule.
  """
  def next(rule, opts \\ [])

  def next(rule, opts) when is_binary(rule) do
    rule
    |> RRule.Parser.ICal.parse()
    |> next(opts)
  end

  def next(%Rule{} = rule, opts) do
    start = Keyword.get(opts, :start, DateTime.utc_now())

    rule
    |> next_after(start, opts)
    |> filter_by_until(rule)
  end

  defp filter_by_until(dt, %Rule{until: nil}), do: dt

  defp filter_by_until(dt, %Rule{until: until}) do
    if Timex.compare(dt, until) < 1 do
      dt
    else
      nil
    end
  end

  defp next_for_frequency(%Rule{freq: :monthly} = rule, start),
    do: next_for_monthly(rule, start)

  defp next_for_frequency(%Rule{freq: :weekly} = rule, start),
    do: next_for_weekly(rule, start)

  # TODO: implement
  defp next_for_frequency(_rule, start), do: start

  defp next_for_monthly(%Rule{bysetpos: [setpos], byweekday: [day]} = rule, start) do
    start
    |> shift(:months, rule.interval)
    |> shift_to_nth_weekday(day, setpos)
    |> set_time(rule)
  end

  defp next_for_monthly(%Rule{bymonthday: [monthday]} = rule, start) when monthday < 0 do
    start
    |> shift(:months, rule.interval)
    |> Timex.end_of_month()
    |> shift(:days, monthday + 1)
    |> set_time(rule)
  end

  defp next_for_monthly(rule, start) do
    shift(start, :months, rule.interval)
  end

  defp next_for_weekly(%Rule{} = rule, start) do
    shift(start, :days, 7 * rule.interval)
  end

  defp set_time(dt, %Rule{byhour: [hour], byminute: [minute], bysecond: [second]}) do
    %{dt | hour: hour, minute: minute, second: second}
  end

  defp shift(dt, field, count),
    do: Timex.shift(dt, "#{field}": count)

  def expand_rule(rule, _opts) do
    rule
    |> maybe_expand_frequency()
    |> maybe_expand_interval()
    |> maybe_expand_hours()
    |> maybe_expand_minutes()
    |> maybe_expand_seconds()
  end

  defp maybe_expand_frequency(
         %Rule{freq: :yearly, byweekno: nil, byyearday: nil, bymonthday: nil, byweekday: nil} =
           rule
       ) do
    case rule.bymonth do
      nil ->
        %{rule | bymonth: rule.dtstart.month, bymonthday: rule.dtstart.day}

      _ ->
        %{rule | bymonthday: rule.dtstart.day}
    end
  end

  defp maybe_expand_frequency(
         %Rule{freq: :monthly, byweekno: nil, byyearday: nil, bymonthday: nil, byweekday: nil} =
           rule
       ) do
    %{rule | bymonthday: rule.dtstart.day}
  end

  defp maybe_expand_frequency(
         %Rule{freq: :weekly, byweekno: nil, byyearday: nil, bymonthday: nil, byweekday: nil} =
           rule
       ) do
    weekday =
      rule.dtstart
      |> Timex.weekday()
      |> to_weekday()

    %{rule | byweekday: [weekday]}
  end

  defp maybe_expand_frequency(rule), do: rule

  defp maybe_expand_interval(%Rule{interval: nil} = rule),
    do: %{rule | interval: 1}

  defp maybe_expand_interval(rule), do: rule

  defp maybe_expand_hours(%Rule{freq: freq, byhour: nil} = rule) do
    case Util.compare_frequencies(:hourly, freq) do
      :gt -> %{rule | byhour: [rule.dtstart.hour]}
      _ -> rule
    end
  end

  defp maybe_expand_hours(rule), do: rule

  defp maybe_expand_minutes(%Rule{freq: freq, byminute: nil} = rule) do
    case Util.compare_frequencies(:minutely, freq) do
      :gt -> %{rule | byminute: [rule.dtstart.minute]}
      _ -> rule
    end
  end

  defp maybe_expand_minutes(rule), do: rule

  defp maybe_expand_seconds(%Rule{freq: freq, bysecond: nil} = rule) do
    case Util.compare_frequencies(:secondly, freq) do
      :gt -> %{rule | bysecond: [rule.dtstart.second]}
      _ -> rule
    end
  end

  defp maybe_expand_seconds(rule), do: rule

  defp to_weekday(1), do: :monday
  defp to_weekday(2), do: :tuesday
  defp to_weekday(3), do: :wednesday
  defp to_weekday(4), do: :thursday
  defp to_weekday(5), do: :friday
  defp to_weekday(6), do: :saturday
  defp to_weekday(7), do: :sunday
end
