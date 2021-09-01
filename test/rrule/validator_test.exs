defmodule RRule.ValidatorTest do
  use ExUnit.Case
  alias RRule.{Rule, Validator}

  @dtstart ~U[2021-01-01T00:00:00Z]

  describe "validate/1" do
    test "returns ok when using byweekno with yearly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :yearly,
        byweekno: [1, 2, 3]
      }

      assert {:ok, _} = Validator.validate(rule)
    end

    test "returns error when using byweekno with monthly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :monthly,
        byweekno: [1, 2, 3]
      }

      assert {:error, "byweekno is not allowed for monthly recurrence"} = Validator.validate(rule)
    end

    test "returns error when using byweekno with weekly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :weekly,
        byweekno: [1, 2, 3]
      }

      assert {:error, "byweekno is not allowed for weekly recurrence"} = Validator.validate(rule)
    end

    test "returns error when using byweekno with daily freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :daily,
        byweekno: [1, 2, 3]
      }

      assert {:error, "byweekno is not allowed for daily recurrence"} = Validator.validate(rule)
    end

    test "returns error when using byweekno with hourly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :hourly,
        byweekno: [1, 2, 3]
      }

      assert {:error, "byweekno is not allowed for hourly recurrence"} = Validator.validate(rule)
    end

    test "returns error when using byweekno with minutely freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :minutely,
        byweekno: [1, 2, 3]
      }

      assert {:error, "byweekno is not allowed for minutely recurrence"} =
               Validator.validate(rule)
    end

    test "returns error when using byweekno with secondly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :secondly,
        byweekno: [1, 2, 3]
      }

      assert {:error, "byweekno is not allowed for secondly recurrence"} =
               Validator.validate(rule)
    end

    test "returns error when using byyearday with monthly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :monthly,
        byyearday: [1, 2, 3]
      }

      assert {:error, "byyearday is not allowed for monthly recurrence"} =
               Validator.validate(rule)
    end

    test "returns error when using byyearday with weekly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :weekly,
        byyearday: [1, 2, 3]
      }

      assert {:error, "byyearday is not allowed for weekly recurrence"} = Validator.validate(rule)
    end

    test "returns error when using byyearday with daily freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :daily,
        byyearday: [1, 2, 3]
      }

      assert {:error, "byyearday is not allowed for daily recurrence"} = Validator.validate(rule)
    end

    test "returns error when using bymonthday with weekly freq" do
      rule = %Rule{
        dtstart: @dtstart,
        freq: :weekly,
        bymonthday: [1, 2, 3]
      }

      assert {:error, "bymonthday is not allowed for weekly recurrence"} =
               Validator.validate(rule)
    end
  end
end
