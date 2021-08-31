defmodule RRule.Validator do
  alias RRule.Rule

  @spec validate(Rule.t()) :: {:ok, Rule.t()} | {:error, String.t()}
  def validate(rule) do
    with :ok <- validate_byweekno(rule),
         :ok <- validate_byyearday(rule),
         :ok <- validate_bymonthday(rule) do
      {:ok, rule}
    end
  end

  defp validate_byweekno(%Rule{freq: freq, byweekno: weekno})
       when freq != :yearly and not is_nil(weekno),
       do: {:error, "byweekno is not allowed for #{freq} recurrence"}

  defp validate_byweekno(_rule), do: :ok

  defp validate_byyearday(%Rule{freq: freq, byyearday: yearday})
       when freq in [:daily, :weekly, :monthly] and not is_nil(yearday),
       do: {:error, "byyearday is not allowed for #{freq} recurrence"}

  defp validate_byyearday(_rule), do: :ok

  defp validate_bymonthday(%Rule{freq: :weekly, bymonthday: monthday})
       when not is_nil(monthday),
       do: {:error, "bymonthday is not allowed for weekly recurrence"}

  defp validate_bymonthday(_rule), do: :ok
end
