defmodule RRule.Serializer.ICal do
	alias RRule.Rule

	@time_format_string "{YYYY}{0M}{0D}T{h24}{m}{s}"

	@spec serialize(RRule.RuleSet.t()) :: String.t()
	def serialize(ruleset) do
		[rrule] = ruleset.rrules
		serialize_rrule(rrule)
	end

	defp serialize_rrule(rrule) do
		"""
		#{serialize_dtstart(rrule.dtstart)}
		RRULE:#{serialize_rrule_options(rrule)}
		"""
	end

	defp serialize_dtstart(%DateTime{} = dtstart) do
		case dtstart.time_zone do
			nil ->
				"DTSTART:#{serialize_dtstart(dtstart)}"

			tzid ->
				"DTSTART;TZID=#{tzid}:#{serialize_datetime(dtstart)}"
		end
	end

	defp serialize_dtstart(%NaiveDateTime{} = dtstart),
		do: "DTSTART:#{serialize_datetime(dtstart)}"

	defp serialize_rrule_options(rrule) do
		[
			serialize_frequency(rrule),
			serialize_interval(rrule),
			serialize_count(rrule),
			serialize_until(rrule),
			serialize_wkst(rrule),
			serialize_bymonth(rrule),
			serialize_bymonthday(rrule),
			serialize_byyearday(rrule),
			serialize_byweekno(rrule),
			serialize_byweekday(rrule),
			serialize_byhour(rrule),
			serialize_byminute(rrule),
			serialize_bysecond(rrule),
			serialize_bysetpos(rrule)
		]
		|> Enum.reject(&is_nil/1)
		|> Enum.join(";")
	end

	defp serialize_datetime(%DateTime{time_zone: "Etc/UTC"} = dt),
		do: "#{do_serialize_datetime(dt)}Z"

	defp serialize_datetime(dt), do: do_serialize_datetime(dt)

	defp do_serialize_datetime(dt) do
		Timex.format!(dt, @time_format_string)
	end

	defp serialize_frequency(%Rule{freq: :yearly}), do: "FREQ=YEARLY"
	defp serialize_frequency(%Rule{freq: :monthly}), do: "FREQ=MONTHLY"
	defp serialize_frequency(%Rule{freq: :weekly}), do: "FREQ=WEEKLY"
	defp serialize_frequency(%Rule{freq: :daily}), do: "FREQ=DAILY"
	defp serialize_frequency(%Rule{freq: :hourly}), do: "FREQ=HOURLY"
	defp serialize_frequency(%Rule{freq: :minutely}), do: "FREQ=MINUTELY"
	defp serialize_frequency(%Rule{freq: :secondly}), do: "FREQ=SECONDLY"

	defp serialize_interval(%Rule{interval: nil}), do: nil
	defp serialize_interval(%Rule{interval: n}), do: "INTERVAL=#{n}"

	defp serialize_until(%Rule{until: nil}), do: nil
	defp serialize_until(%Rule{until: dt}), do: "UNTIL=#{serialize_datetime(dt)}"

	defp serialize_count(%Rule{count: nil}), do: nil
	defp serialize_count(%Rule{count: n}), do: "COUNT=#{n}"

	defp serialize_wkst(%Rule{wkst: nil}), do: nil
	defp serialize_wkst(%Rule{wkst: wkst}), do: "WKST=#{serialize_weekday(wkst)}"

	defp serialize_bysetpos(%Rule{bysetpos: nil}), do: nil
	defp serialize_bysetpos(%Rule{bysetpos: setpos_list}),
		do: "BYSETPOS=#{Enum.join(setpos_list, ",")}"

	defp serialize_bymonth(%Rule{bymonth: nil}), do: nil
	defp serialize_bymonth(%Rule{bymonth: month_list}),
		do: "BYMONTH=#{Enum.join(month_list, ",")}"

	defp serialize_bymonthday(%Rule{bymonthday: nil}), do: nil
	defp serialize_bymonthday(%Rule{bymonthday: monthday_list}),
		do: "BYMONTHDAY=#{Enum.join(monthday_list, ",")}"

	defp serialize_byyearday(%Rule{byyearday: nil}), do: nil
	defp serialize_byyearday(%Rule{byyearday: yearday_list}),
		do: "BYYEARDAY=#{Enum.join(yearday_list, ",")}"

	defp serialize_byweekno(%Rule{byweekno: nil}), do: nil
	defp serialize_byweekno(%Rule{byweekno: weekno_list}),
		do: "BYWEEKNO=#{Enum.join(weekno_list, ",")}"

	defp serialize_byweekday(%Rule{byweekday: nil}), do: nil
	defp serialize_byweekday(%Rule{byweekday: weekday_list}),
		do: "BYDAY=#{serialize_byweekday_list(weekday_list)}"

	defp serialize_byweekday_list(weekday_list) do
		weekday_list
		|> Enum.map(&serialize_nth_day/1)
		|> Enum.join(",")
	end

	defp serialize_nth_day([num, day]), do: "#{num}#{serialize_weekday(day)}"
	defp serialize_nth_day(day), do: serialize_weekday(day)

	defp serialize_byhour(%Rule{byhour: nil}), do: nil
	defp serialize_byhour(%Rule{byhour: hour_list}),
		do: "BYHOUR=#{Enum.join(hour_list, ",")}"

	defp serialize_byminute(%Rule{byminute: nil}), do: nil
	defp serialize_byminute(%Rule{byminute: minute_list}),
		do: "BYMINUTE=#{Enum.join(minute_list, ",")}"

	defp serialize_bysecond(%Rule{bysecond: nil}), do: nil
	defp serialize_bysecond(%Rule{bysecond: second_list}),
		do: "BYSECOND=#{Enum.join(second_list, ",")}"

	def serialize_weekday(:monday), do: "MO"
	def serialize_weekday(:tuesday), do: "TU"
	def serialize_weekday(:wednesday), do: "WE"
	def serialize_weekday(:thursday), do: "TH"
	def serialize_weekday(:friday), do: "FR"
	def serialize_weekday(:saturday), do: "SA"
	def serialize_weekday(:sunday), do: "SU"
end
