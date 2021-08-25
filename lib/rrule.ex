defmodule RRule do
  alias RRule.RuleSet

  def next_occurrence(ruleset, datetime) do
    RuleSet.next_occurrence(ruleset, datetime)
  end

  def next_occurrences(ruleset, datetime, count) do
    RuleSet.next_occurrences(ruleset, datetime, count)
  end
end
