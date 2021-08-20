defmodule RRule.Rule do
	@type t :: %__MODULE__{
		dtstart: DateTime.t(),
		freq: String.t(),
		interval: integer() | nil,
		tzid: String.t() | nil,
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
	]

	@spec new(options()) :: t()
	def new(opts \\ []), do: struct(__MODULE__, opts)
end
