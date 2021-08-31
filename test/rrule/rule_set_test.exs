defmodule RRule.RuleSetTest do
  use ExUnit.Case
  alias RRule.{Rule, RuleSet}

  @dtstart ~U[2021-01-01T09:00:00Z]
  # @naive_dtstart ~N[]

  describe "next_occurrence/2 when DateTime" do
    test "daily with 10 occurrences" do
      ruleset = %RuleSet{
        rrules: [
          %Rule{
            dtstart: @dtstart,
            freq: :daily,
            count: 10
          }
        ]
      }

      expected1 = DateTime.new(~D[2021-01-02], ~T[09:00:00])
      assert expected1 == RuleSet.next_occurrence(ruleset, start: @dtstart)

      expected2 = DateTime.new(~D[2021-02-02], ~T[09:00:00])
      assert expected2 == RuleSet.next_occurrence(ruleset, start: ~U[2021-02-01T09:00:00Z])
    end

    test "every third day with 10 occurrences" do
      ruleset = %RuleSet{
        rrules: [
          %Rule{
            dtstart: @dtstart,
            freq: :daily,
            interval: 3,
            count: 10
          }
        ]
      }

      expected1 = DateTime.new(~D[2021-01-04], ~T[09:00:00])
      assert expected1 == RuleSet.next_occurrence(ruleset, start: @dtstart)

      expected2 = DateTime.new(~D[2021-02-03], ~T[09:00:00])
      assert expected2 == RuleSet.next_occurrence(ruleset, start: ~U[2021-02-01T09:00:00Z])
    end

    test "monthly for 10 occurrences" do
      ruleset = %RuleSet{
        rrules: [
          %Rule{
            dtstart: @dtstart,
            freq: :monthly,
            count: 10
          }
        ]
      }

      expected1 = DateTime.new(~D[2021-02-01], ~T[09:00:00])
      assert expected1 == RuleSet.next_occurrence(ruleset, start: @dtstart)

      expected2 = DateTime.new(~D[2021-03-01], ~T[09:00:00])
      assert expected2 == RuleSet.next_occurrence(ruleset, start: ~U[2021-02-03T09:00:00Z])
    end

    test "every 6 months for 10 occurrences" do
      ruleset = %RuleSet{
        rrules: [
          %Rule{
            dtstart: @dtstart,
            freq: :monthly,
            interval: 6,
            count: 10
          }
        ]
      }

      expected1 = DateTime.new(~D[2021-07-01], ~T[09:00:00])
      assert expected1 == RuleSet.next_occurrence(ruleset, start: @dtstart)

      expected2 = DateTime.new(~D[2021-07-01], ~T[09:00:00])
      assert expected2 == RuleSet.next_occurrence(ruleset, start: ~U[2021-02-03T09:00:00Z])
    end
  end

  describe "next_occurrences/3 when DateTime" do
    test "daily with 10 occurrences" do
      ruleset = %RuleSet{
        rrules: [
          %Rule{
            dtstart: @dtstart,
            freq: :daily,
            count: 10
          }
        ]
      }

      expected1 = DateTime.new!(~D[2021-01-02], ~T[09:00:00])
      expected2 = DateTime.new!(~D[2021-01-03], ~T[09:00:00])
      expected3 = DateTime.new!(~D[2021-01-04], ~T[09:00:00])
      assert {:ok, [dt1, dt2, dt3]} = RuleSet.next_occurrences(ruleset, 3, start: @dtstart)
      assert expected1 == dt1
      assert expected2 == dt2
      assert expected3 == dt3

      expected1 = DateTime.new!(~D[2021-02-02], ~T[09:00:00])
      expected2 = DateTime.new!(~D[2021-02-03], ~T[09:00:00])
      expected3 = DateTime.new!(~D[2021-02-04], ~T[09:00:00])

      assert {:ok, [dt1, dt2, dt3]} =
               RuleSet.next_occurrences(ruleset, 3, start: ~U[2021-02-01T09:00:00Z])

      assert expected1 == dt1
      assert expected2 == dt2
      assert expected3 == dt3
    end
  end
end
