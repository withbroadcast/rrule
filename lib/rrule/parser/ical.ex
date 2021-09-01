defmodule RRule.Parser.ICal do
  alias RRule.Rule

  @time_regex ~r/^:?;?(?:TZID=(.+?):)?(.*?)(Z)?$/
  @datetime_format "{YYYY}{0M}{0D}T{h24}{m}{s}"
  # @time_format "{h24}{m}{s}"

  @spec parse(String.t()) :: {:ok, Rule.t()} | {:error, term()}
  def parse(str) when is_binary(str) do
    ruleset =
      str
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reduce(%Rule{}, &parse_line/2)

    case ruleset.errors do
      %{} -> {:ok, ruleset}
      _ -> {:error, ruleset}
    end
  end

  defp parse_line(line, rule_set)

  defp parse_line("DTSTART" <> time_string, rule),
    do: parse_dtstart(time_string, rule)

  defp parse_line("DTEND" <> time_string, rule),
    do: parse_dtend(time_string, rule)

  defp parse_line("RRULE:" <> rrule_string, rule),
    do: parse_rrule(rrule_string, rule)

  defp parse_line("RDATE" <> time_string, rule),
    do: parse_rdate(time_string, rule)

  defp parse_line("EXDATE" <> time_string, rule),
    do: parse_exdate(time_string, rule)

  defp parse_line(_, _), do: {:error, :unknown_option}

  ## DTSTART

  defp parse_dtstart(time_string, rule) do
    case parse_datetime(time_string) do
      {:ok, dt} ->
        %{rule | dtstart: dt}

      {:error, reason} ->
        Rule.add_error(rule, :dtstart, reason)
    end
  end

  ## DTEND

  defp parse_dtend(_time_string, rule) do
    rule
  end

  ## RRULE

  defp parse_rrule(rrule_string, rule) do
    case parse_rrule_options_string(rrule_string) do
      {:error, reason} ->
        Rule.add_error(rule, :rrule, reason)

      {:ok, opts} ->
        %{Rule.new(opts) | dtstart: rule.dtstart}
    end
  end

  @spec parse_rrule_options_string(String.t()) :: {:ok, Rule.t()} | {:error, term()}
  defp parse_rrule_options_string(options_string) do
    options_string
    |> String.split(";")
    |> parse_rrule_options([])
  end

  defp parse_rrule_options([], options), do: {:ok, options}

  defp parse_rrule_options([option_string | rest], options) do
    with {:ok, opt} <- parse_rrule_option(option_string) do
      parse_rrule_options(rest, [opt | options])
    end
  end

  defp parse_rrule_option("FREQ=" <> frequency_string) do
    with {:ok, freq} <- parse_frequency(frequency_string) do
      {:ok, {:freq, freq}}
    end
  end

  defp parse_rrule_option("INTERVAL=" <> interval_string) do
    with {:ok, interval} <- parse_interval(interval_string) do
      {:ok, {:interval, interval}}
    end
  end

  defp parse_rrule_option("COUNT=" <> count_string) do
    with {:ok, count} <- parse_count(count_string) do
      {:ok, {:count, count}}
    end
  end

  defp parse_rrule_option("UNTIL=" <> until_string) do
    with {:ok, until} <- parse_datetime(until_string) do
      {:ok, {:until, until}}
    end
  end

  defp parse_rrule_option("WKST=" <> wkst_string) do
    with {:ok, wkst} <- parse_weekday(wkst_string) do
      {:ok, {:wkst, wkst}}
    end
  end

  defp parse_rrule_option("BYSETPOS=" <> bysetpos_string) do
    with {:ok, bysetpos} <- parse_byyearday(bysetpos_string) do
      {:ok, {:bysetpos, bysetpos}}
    end
  end

  defp parse_rrule_option("BYMONTH=" <> bymonth_string) do
    with {:ok, bymonth} <- parse_bymonth(bymonth_string) do
      {:ok, {:bymonth, Enum.sort(bymonth)}}
    end
  end

  defp parse_rrule_option("BYMONTHDAY=" <> bymonthday_string) do
    with {:ok, bymonthday} <- parse_bymonthday(bymonthday_string) do
      {:ok, {:bymonthday, Enum.sort(bymonthday)}}
    end
  end

  defp parse_rrule_option("BYYEARDAY=" <> byyearday_string) do
    with {:ok, byyearday} <- parse_byyearday(byyearday_string) do
      {:ok, {:byyearday, Enum.sort(byyearday)}}
    end
  end

  defp parse_rrule_option("BYWEEKNO=" <> byweekno_string) do
    with {:ok, byweekno} <- parse_byweekno(byweekno_string) do
      {:ok, {:byweekno, byweekno}}
    end
  end

  defp parse_rrule_option("BYDAY=" <> byweekday_string) do
    with {:ok, byweekday} <- parse_byday(byweekday_string) do
      {:ok, {:byweekday, Enum.reverse(byweekday)}}
    end
  end

  defp parse_rrule_option("BYHOUR=" <> byhour_string) do
    with {:ok, byhour} <- parse_byhour(byhour_string) do
      {:ok, {:byhour, Enum.sort(byhour)}}
    end
  end

  defp parse_rrule_option("BYMINUTE=" <> byminute_string) do
    with {:ok, byminute} <- parse_byminute(byminute_string) do
      {:ok, {:byminute, Enum.sort(byminute)}}
    end
  end

  defp parse_rrule_option("BYSECOND=" <> bysecond_string) do
    with {:ok, bysecond} <- parse_bysecond(bysecond_string) do
      {:ok, {:bysecond, Enum.sort(bysecond)}}
    end
  end

  defp parse_rrule_option(_), do: {:error, :unknown_rrule_option}

  @spec parse_frequency(String.t()) :: {:ok, Rule.frequency()} | {:error, term()}
  defp parse_frequency("YEARLY"), do: {:ok, :yearly}
  defp parse_frequency("MONTHLY"), do: {:ok, :monthly}
  defp parse_frequency("WEEKLY"), do: {:ok, :weekly}
  defp parse_frequency("DAILY"), do: {:ok, :daily}
  defp parse_frequency("HOURLY"), do: {:ok, :hourly}
  defp parse_frequency("MINUTELY"), do: {:ok, :minutely}
  defp parse_frequency("SECONDLY"), do: {:ok, :secondly}
  defp parse_frequency(_), do: {:error, :invalid_frequency}

  defp positive?(num) when num > 0, do: true
  defp positive?(_), do: false

  defp parse_count(count_string) do
    with {integer, _} <- Integer.parse(count_string),
         true <- positive?(integer) do
      {:ok, integer}
    else
      _ -> {:error, :invalid_count}
    end
  end

  defp parse_interval(interval_string) do
    with {integer, _} <- Integer.parse(interval_string),
         true <- positive?(integer) do
      {:ok, integer}
    else
      _ -> {:error, :invalid_interval}
    end
  end

  defp parse_bymonth(bymonth_string) do
    bymonth_string
    |> String.split(",")
    |> parse_months([])
  end

  defp parse_months([], months), do: {:ok, months}

  defp parse_months([month_string | rest], months) do
    with {:ok, month} <- parse_month(month_string) do
      parse_months(rest, [month | months])
    end
  end

  defp parse_month(month_string) do
    with {month, ""} <- Integer.parse(month_string),
         true <- month in -12..1 or month in 1..12 do
      {:ok, month}
    else
      _ -> {:error, :invalid_month}
    end
  end

  defp parse_bymonthday(bymonthdays_string) do
    bymonthdays_string
    |> String.split(",")
    |> parse_monthdays([])
  end

  defp parse_monthdays([], mdays), do: {:ok, mdays}

  defp parse_monthdays([mday_string | rest], mdays) do
    with {:ok, mday} <- parse_monthday(mday_string) do
      parse_monthdays(rest, [mday | mdays])
    end
  end

  defp parse_monthday(mday_string) do
    with {mday, ""} <- Integer.parse(mday_string),
         true <- mday in -31..-1 or mday in 1..31 do
      {:ok, mday}
    else
      _ -> {:error, :invalid_mday}
    end
  end

  defp parse_byyearday(byyearday_string) do
    byyearday_string
    |> String.split(",")
    |> parse_yeardays([])
  end

  defp parse_yeardays([], ydays), do: {:ok, ydays}

  defp parse_yeardays([yday_string | rest], ydays) do
    with {:ok, yday} <- parse_yearday(yday_string) do
      parse_yeardays(rest, [yday | ydays])
    end
  end

  defp parse_yearday(byyearday_string) do
    with {yearday, ""} <- Integer.parse(byyearday_string),
         true <- yearday in -366..-1 or yearday in 1..366 do
      {:ok, yearday}
    else
      _ -> {:error, :invalid_byyearday}
    end
  end

  defp parse_byweekno(byweekno_string) do
    byweekno_string
    |> String.split(",")
    |> parse_weeknos([])
  end

  defp parse_weeknos([], wnos), do: {:ok, wnos}

  defp parse_weeknos([wno_string | rest], wnos) do
    with {:ok, wno} <- parse_weekno(wno_string) do
      parse_weeknos(rest, [wno | wnos])
    end
  end

  defp parse_weekno(byweekno_string) do
    with {weekno, ""} <- Integer.parse(byweekno_string),
         true <- weekno in -53..-1 or weekno in 1..53 do
      {:ok, weekno}
    else
      _ -> {:error, :invalid_byweekno}
    end
  end

  defp parse_byday(days_string) do
    days_string
    |> String.split(",")
    |> parse_weekdays([])
  end

  defp parse_weekdays([], wdays), do: {:ok, wdays}

  defp parse_weekdays([wday_string | rest], wdays) do
    with {:ok, wday} <- parse_day(wday_string) do
      parse_weekdays(rest, [wday | wdays])
    end
  end

  @day_regex ~r/^(?<num>[-+]*\d*)(?<day>MO|TU|WE|TH|FR|SA|SU)$/

  defp parse_day(day_string) do
    case Regex.run(@day_regex, day_string) do
      [_, "", day] ->
        parse_weekday(day)

      [_, num_string, day] ->
        parse_nth_day(num_string, day)

      _ ->
        {:error, :invalid_day}
    end
  end

  defp parse_nth_day(num_string, day) do
    with {:ok, day} <- parse_weekday(day),
         {num, ""} <- Integer.parse(num_string) do
      {:ok, [num, day]}
    else
      _ -> {:error, :invalid_nth_day}
    end
  end

  defp parse_weekday("SU"), do: {:ok, :sunday}
  defp parse_weekday("MO"), do: {:ok, :monday}
  defp parse_weekday("TU"), do: {:ok, :tuesday}
  defp parse_weekday("WE"), do: {:ok, :wednesday}
  defp parse_weekday("TH"), do: {:ok, :thursday}
  defp parse_weekday("FR"), do: {:ok, :friday}
  defp parse_weekday("SA"), do: {:ok, :saturday}
  defp parse_weekday(_), do: {:error, :invalid_day}

  defp parse_byhour(byhour_string) do
    byhour_string
    |> String.split(",")
    |> parse_hours([])
  end

  defp parse_hours([], hours), do: {:ok, hours}

  defp parse_hours([hour_string | rest], hours) do
    with {:ok, hour} <- parse_hour(hour_string) do
      parse_hours(rest, [hour | hours])
    end
  end

  defp parse_hour(byhour_string) do
    with {hour, ""} <- Integer.parse(byhour_string),
         true <- hour in 0..23 do
      {:ok, hour}
    else
      _ -> {:error, :invalid_hour}
    end
  end

  defp parse_byminute(byminute_string) do
    byminute_string
    |> String.split(",")
    |> parse_minutes([])
  end

  defp parse_minutes([], minutes), do: {:ok, minutes}

  defp parse_minutes([minute_string | rest], minutes) do
    with {:ok, minute} <- parse_minute(minute_string) do
      parse_minutes(rest, [minute | minutes])
    end
  end

  defp parse_minute(byminute_string) do
    with {minute, ""} <- Integer.parse(byminute_string),
         true <- minute in 0..59 do
      {:ok, minute}
    else
      _ -> {:error, :invalid_minute}
    end
  end

  defp parse_bysecond(bysecond_string) do
    bysecond_string
    |> String.split(",")
    |> parse_seconds([])
  end

  defp parse_seconds([], seconds), do: {:ok, seconds}

  defp parse_seconds([second_string | rest], seconds) do
    with {:ok, second} <- parse_second(second_string) do
      parse_seconds(rest, [second | seconds])
    end
  end

  defp parse_second(bysecond_string) do
    with {second, ""} <- Integer.parse(bysecond_string),
         true <- second in 0..59 do
      {:ok, second}
    else
      _ -> {:error, :invalid_second}
    end
  end

  ## RDATE

  defp parse_rdate(_time_string, rule) do
    rule
  end

  ## EXDATE

  defp parse_exdate(_time_string, rule) do
    rule
  end

  ## Helpers

  def parse_datetime(time_string) do
    case Regex.run(@time_regex, time_string) do
      [_, "", time_string] ->
        parse_naive_datetime(time_string)

      [_, "", time_string, "Z"] ->
        parse_utc_datetime(time_string)

      [_, tzid, time_string] ->
        zone = normalize_zone_name(tzid)
        parse_zoned_datetime(time_string, zone)

      _ ->
        {:error, :invalid_time_format}
    end
  end

  @spec parse_naive_datetime(String.t()) :: {:ok, NaiveDateTime.t()} | {:error, term}
  defp parse_naive_datetime(time_string), do: Timex.parse(time_string, @datetime_format)

  @spec parse_utc_datetime(String.t()) :: {:ok, DateTime.t()} | {:error, term}
  defp parse_utc_datetime(time_string), do: parse_zoned_datetime(time_string, "UTC")

  @spec parse_zoned_datetime(String.t(), String.t()) :: {:ok, DateTime.t()} | {:error, term}
  defp parse_zoned_datetime(time_string, zone) do
    with {:ok, naive_datetime} <- Timex.parse(time_string, @datetime_format),
         %DateTime{} = datetime <- Timex.to_datetime(naive_datetime, zone) do
      {:ok, datetime}
    end
  end

  # Some of the RFC timezone names are of the form "US-Eastern" which is no longer
  # considered to be a valid timezone name. This function converts the dash to a slash.
  defp normalize_zone_name(zone) do
    String.replace(zone, "-", "/")
  end
end
