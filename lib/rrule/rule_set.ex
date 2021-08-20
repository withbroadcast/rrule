defmodule RRule.RuleSet do
	@type dtstart :: DateTime.t() | NaiveDateTime.t() | nil

	@type t :: %__MODULE__{
		dtstart: dtstart(),
		rrules: [RRule.Rule.t()],
		errors: map()
	}

	defstruct [
		:dtstart,
		rrules: [],
		errors: %{}
	]

	@spec add_error(t(), atom(), String.t() | atom()) :: t()
	def add_error(ruleset, key, value) do
		# Probably a cleaner way to do this...
		errors = ruleset.errors
		errors_for_key = Map.get(errors, key, [])
		new_errors_for_key = [value | errors_for_key]

		%{ruleset | errors: Map.put(errors, key, new_errors_for_key)}
	end

	@spec put_dtstart(t(), dtstart()) :: t()
	def put_dtstart(ruleset, dtstart) do
		%{ruleset | dtstart: dtstart}
	end

	@spec add_rrule(t(), RRule.Rule.t()) :: t()
	def add_rrule(ruleset, rrule) do
		%{ruleset | rrules: [rrule | ruleset.rrules]}
	end
end
