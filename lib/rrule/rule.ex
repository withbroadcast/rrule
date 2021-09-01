defmodule RRule.Rule do
  @type t :: %__MODULE__{
          dtstart: DateTime.t(),
          freq: String.t(),
          interval: integer() | nil,
          tzid: String.t() | nil
        }

  @type frequency :: :yearly | :monthly | :weekly | :daily | :hourly | :minutely | :secondly

  @type day_number :: 0..6
  @type day_atom :: :sunday | :monday | :tuesday | :wednesday | :thursday | :friday | :saturday
  @type day :: day_number | day_atom

  @type day_of_month :: -31..-1 | 1..31
  @type day_of_year :: -366..-1 | 1..366

  @type hour_number :: 0..23
  @type minute_number :: 0..59
  @type second_number :: 0..59

  @type time :: DateTime.t() | NaiveDateTime.t()

  @type option ::
          {:frequency, frequency()}
          | {:interval, pos_integer()}
          | {:count, pos_integer()}
          | {:until, time()}
          | {:byweekday, [day()]}
          | {:bymonthday, [day_of_month()]}
          | {:byhour, [hour_number()]}
          | {:byminute, [minute_number()]}
          | {:bysecond, [second_number()]}

  @type options :: [option()]

  defstruct [
    :dtstart,
    :freq,
    :tzid,
    :count,
    :until,
    :bysetpos,
    :bymonth,
    :bymonthday,
    :byyearday,
    :byweekno,
    :byweekday,
    :byhour,
    :byminute,
    :bysecond,
    interval: 1,
    wkst: :monday,
    errors: %{}
  ]

  @spec new(options()) :: t()
  def new(opts \\ []), do: struct(__MODULE__, opts)

  @spec add_error(t(), atom(), String.t() | atom()) :: t()
  def add_error(rule, key, value) do
    # Probably a cleaner way to do this...
    errors = rule.errors
    errors_for_key = Map.get(errors, key, [])
    new_errors_for_key = [value | errors_for_key]

    %{rule | errors: Map.put(errors, key, new_errors_for_key)}
  end

  def first_occurrence(rule, _opts \\ []), do: rule.dtstart

  @doc """
  Generates the next occurrence of the rule. If the `start` option is provided,
  the next occurrence _after `start`_ will be returned.

  See `first_occurrence/2` in order to get the first occurrence of the rule.
  """
  def next_occurrence(%__MODULE__{dtstart: %mod{} = dtstart} = rule, opts \\ []) do
    # Evaluation order:
    # FREQ, INTERVAL
    # BYMONTH, BYWEEKNO, BYYEARDAY, BYMONTHDAY, BYDAY,
    # BYHOUR, BYMINUTE, BYSECOND, BYSETPOS
    # COUNT, UNTIL
    #
    # Treat `start` as the current datetime.
    start = Keyword.get(opts, :start, mod.utc_now())

    {:ok,
     start
     |> apply_frequency(rule.freq, rule.interval, dtstart)
     |> apply_default_day(rule)
     |> apply_time(dtstart)}
  end

  def next_occurrences(%__MODULE__{dtstart: %mod{}} = rule, count, opts \\ []) do
    start = Keyword.get(opts, :start, mod.utc_now())

    %{occurrences: occurrences} =
      Enum.reduce(1..count, %{start: start, occurrences: []}, fn _,
                                                                 %{
                                                                   start: start,
                                                                   occurrences: occurrences
                                                                 } ->
        {:ok, next} = next_occurrence(rule, start: start)
        %{start: next, occurrences: [next | occurrences]}
      end)

    {:ok, Enum.reverse(occurrences)}
  end

  ## Helpers

  defp apply_frequency(dt, :yearly, interval, dtstart) do
    diff =
      dtstart
      |> Timex.beginning_of_year()
      |> Timex.diff(Timex.beginning_of_year(dt), :years)
      |> Integer.mod(interval)

    case diff do
      0 -> Timex.shift(dt, years: interval)
      amount -> Timex.shift(dt, years: amount)
    end
  end

  defp apply_frequency(dt, :monthly, interval, dtstart) do
    diff =
      dtstart
      |> Timex.beginning_of_month()
      |> Timex.diff(Timex.beginning_of_month(dt), :months)
      |> Integer.mod(interval)

    case diff do
      0 -> Timex.shift(dt, months: interval)
      amount -> Timex.shift(dt, months: amount)
    end
  end

  defp apply_frequency(dt, :weekly, interval, dtstart) do
    diff =
      dtstart
      |> Timex.beginning_of_week()
      |> Timex.diff(Timex.beginning_of_week(dt), :weeks)
      |> Integer.mod(interval)

    case diff do
      0 -> Timex.shift(dt, weeks: interval)
      amount -> Timex.shift(dt, weeks: amount)
    end
  end

  # Get the difference between the dt and current_time, modded by the interval
  # to see how many additional days should be added to `current_time` in order to
  # get the next time.
  # ex. If dtstart is 2021-01-01 and current_time is 2021-02-02 with interval 1,
  # 			we would simply add a day.
  # ex. If dtstart is 2021-01-01 and current_time is 2021-02-02 with interval 2,
  # 			we would mod the number of days between the two dates to determine how
  # 		many days to add to maintain the interval
  defp apply_frequency(dt, :daily, interval, dtstart) do
    date = Timex.to_date(dt)
    start_date = Timex.to_date(dtstart)

    diff =
      start_date
      |> Timex.diff(date, :days)
      |> Integer.mod(interval)

    case diff do
      0 -> Timex.shift(dt, days: interval)
      amount -> Timex.shift(dt, days: amount)
    end
  end

  # TODO
  defp apply_frequency(dt, :hourly, _interval, _dtstart) do
    dt
  end

  # TODO
  defp apply_frequency(dt, :minutely, _interval, _dtstart) do
    dt
  end

  # TODO
  defp apply_frequency(dt, :secondly, _interval, _dtstart) do
    dt
  end

  defp apply_default_day(dt, %__MODULE__{
         freq: :monthly,
         bymonthday: nil,
         byweekday: nil,
         bysetpos: nil,
         dtstart: dtstart
       }) do
    # TODO: handle different month lengths.
    %{dt | day: dtstart.day}
  end

  defp apply_default_day(dt, _), do: dt

  defp apply_time(dt, dtstart) do
    %{dt | hour: dtstart.hour, minute: dtstart.minute, second: dtstart.second}
  end
end
