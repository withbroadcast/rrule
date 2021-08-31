defmodule RRule.Test do
  use ExUnit.Case
  alias RRule.Rule

  describe "all/2" do
    test "weekly" do
      # Monday
      dtstart = ~U[2021-08-30T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-08-30T09:00:00Z]
      assert dt2 == ~U[2021-09-06T09:00:00Z]
      assert dt3 == ~U[2021-09-13T09:00:00Z]
    end

    test "weekly with until" do
      # Monday
      dtstart = ~U[2021-08-30T09:00:00Z]
      until = ~U[2021-09-12T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly,
        until: until
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-08-30T09:00:00Z]
      assert dt2 == ~U[2021-09-06T09:00:00Z]
      assert is_nil(dt3)
    end

    test "weekly on Friday" do
      # Friday
      dtstart = ~U[2021-09-03T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-03T09:00:00Z]
      assert dt2 == ~U[2021-09-10T09:00:00Z]
      assert dt3 == ~U[2021-09-17T09:00:00Z]
    end

    test "biweekly on Wednesday" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly,
        interval: 2
      }

      [dt1, dt2, dt3, dt4] = RRule.all(rule) |> Enum.take(4)
      assert dt1 == ~U[2021-09-01T09:00:00Z]
      assert dt2 == ~U[2021-09-15T09:00:00Z]
      assert dt3 == ~U[2021-09-29T09:00:00Z]
      assert dt4 == ~U[2021-10-13T09:00:00Z]
    end

    test "biweekly on Tuesday" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly,
        byweekday: [:tuesday],
        interval: 2
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-07T09:00:00Z]
      assert dt2 == ~U[2021-09-21T09:00:00Z]
      assert dt3 == ~U[2021-10-05T09:00:00Z]
    end

    test "monthly" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :monthly
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-01T09:00:00Z]
      assert dt2 == ~U[2021-10-01T09:00:00Z]
      assert dt3 == ~U[2021-11-01T09:00:00Z]
    end

    test "monthly on the 4th" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :monthly,
        bymonthday: [4]
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-04T09:00:00Z]
      assert dt2 == ~U[2021-10-04T09:00:00Z]
      assert dt3 == ~U[2021-11-04T09:00:00Z]
    end

    test "monthly on the 2nd Tuesday" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :monthly,
        byweekday: [:tuesday],
        bysetpos: [2]
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-14T09:00:00Z]
      assert dt2 == ~U[2021-10-12T09:00:00Z]
      assert dt3 == ~U[2021-11-09T09:00:00Z]
    end

    test "monthly on the last Friday" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :monthly,
        byweekday: [:friday],
        bysetpos: [-1]
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-24T09:00:00Z]
      assert dt2 == ~U[2021-10-29T09:00:00Z]
      assert dt3 == ~U[2021-11-26T09:00:00Z]
    end

    test "monthly on the last day" do
      # Wednesday
      dtstart = ~U[2021-09-01T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :monthly,
        bymonthday: [-1]
      }

      [dt1, dt2, dt3] = RRule.all(rule) |> Enum.take(3)
      assert dt1 == ~U[2021-09-30T09:00:00Z]
      assert dt2 == ~U[2021-10-31T09:00:00Z]
      assert dt3 == ~U[2021-11-30T09:00:00Z]
    end
  end

  describe "next/2" do
    test "weekly" do
      # Monday
      dtstart = ~U[2021-08-30T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly
      }

      expected1 = ~U[2021-09-06T09:00:00Z]
      assert expected1 == RRule.next(rule, start: ~U[2021-09-01T12:00:00Z])

      expected2 = ~U[2021-09-13T09:00:00Z]
      assert expected2 == RRule.next(rule, start: ~U[2021-09-09T12:00:00Z])
    end

    test "weekly on friday" do
      # Friday
      dtstart = ~U[2021-09-03T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly,
        byweekday: [:friday]
      }

      expected1 = ~U[2021-09-03T09:00:00Z]
      assert expected1 == RRule.next(rule, start: ~U[2021-09-01T12:00:00Z])

      expected2 = ~U[2021-09-10T09:00:00Z]
      assert expected2 == RRule.next(rule, start: ~U[2021-09-09T12:00:00Z])
    end

    test "biweekly" do
      # Monday
      dtstart = ~U[2021-08-30T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly,
        interval: 2
      }

      expected1 = ~U[2021-09-13T09:00:00Z]
      assert expected1 == RRule.next(rule, start: ~U[2021-09-01T12:00:00Z])

      expected2 = ~U[2021-09-27T09:00:00Z]
      assert expected2 == RRule.next(rule, start: ~U[2021-09-17T12:00:00Z])
    end

    test "biweekly on thursday" do
      # Thursday
      dtstart = ~U[2021-09-02T09:00:00Z]

      rule = %Rule{
        dtstart: dtstart,
        freq: :weekly,
        interval: 2,
        byweekday: [:thursday]
      }

      expected1 = ~U[2021-09-02T09:00:00Z]
      assert expected1 == RRule.next(rule, start: ~U[2021-09-01T12:00:00Z])

      expected2 = ~U[2021-09-16T09:00:00Z]
      assert expected2 == RRule.next(rule, start: ~U[2021-09-03T12:00:00Z])

      expected3 = ~U[2021-09-30T09:00:00Z]
      assert expected3 == RRule.next(rule, start: ~U[2021-09-18T12:00:00Z])
    end
  end
end
