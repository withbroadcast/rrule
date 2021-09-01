defmodule RRule.RuleSet do
  alias RRule.Rule

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

  @doc """
  Returns the datetime for the next occurrence of the ruleset.

  If `start` is provided, it will return the next occurrence after that
  datetime.  If `start` is not provided, it will return the next occurrence
  after the current datetime.
  """
  def next_occurrence(ruleset, opts \\ []) do
    [rrule] = ruleset.rrules
    Rule.next_occurrence(rrule, opts)
  end

  def next_occurrences(ruleset, count, opts \\ []) do
    [rrule] = ruleset.rrules
    Rule.next_occurrences(rrule, count, opts)
  end
end
