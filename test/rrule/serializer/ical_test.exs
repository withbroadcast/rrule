defmodule RRule.Serializer.ICalTest do
	use ExUnit.Case
	alias RRule.{Rule, RuleSet}
	alias RRule.Serializer.ICal

	@dtstart ~U[1997-09-02T09:00:00Z]

	describe "serialize" do
		test "daily with 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :daily,
					count: 10
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=DAILY;INTERVAL=1;COUNT=10;WKST=MO
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "monthly for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					count: 10
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;COUNT=10;WKST=MO
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "weekly for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :weekly,
					count: 10
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=WEEKLY;INTERVAL=1;COUNT=10;WKST=MO
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every 5 weeks on Monday and Friday until 2013-01-30 at 11pm" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :weekly,
					interval: 5,
					until: ~U[2013-01-30T23:00:00Z],
					byweekday: [:monday, :friday]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=WEEKLY;INTERVAL=5;UNTIL=20130130T230000Z;WKST=MO;BYDAY=MO,FR
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every other week on Monday, Wednesday and Friday until December 24, 1997, but starting on Tuesday, September 2, 1997" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :weekly,
					interval: 2,
					until: ~U[1997-12-24T00:00:00Z],
					wkst: :sunday,
					byweekday: [:monday, :wednesday, :friday],
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every other month on the 1st and last Sunday of the month for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					interval: 2,
					count: 10,
					byweekday: [[1, :sunday], [-1, :sunday]]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;WKST=MO;BYDAY=1SU,-1SU
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "monthly on the second to last Monday of the month for 6 months" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					count: 6,
					byweekday: [[-2, :monday]]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;COUNT=6;WKST=MO;BYDAY=-2MO
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "monthly on the third to the last day of the month forever" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					bymonthday: [-3]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;WKST=MO;BYMONTHDAY=-3
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "monthly on the 2nd and 15th of the month for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					count: 10,
					bymonthday: [2, 15]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;COUNT=10;WKST=MO;BYMONTHDAY=2,15
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "monthly on the first and last day of the month for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					count: 10,
					bymonthday: [1, -1]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;COUNT=10;WKST=MO;BYMONTHDAY=1,-1
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every 18 months on the 10th thru 15th of the month for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					interval: 18,
					count: 10,
					bymonthday: [10, 11, 12, 13, 14, 15]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;WKST=MO;BYMONTHDAY=10,11,12,13,14,15
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every 3rd year on the 1st, 100th and 200th day for 10 occurrences" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :yearly,
					interval: 3,
					count: 10,
					byyearday: [1, 100, 200]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;WKST=MO;BYYEARDAY=1,100,200
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every 20th Monday of the year, forever" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :yearly,
					byweekday: [[20, :monday]]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=YEARLY;INTERVAL=1;WKST=MO;BYDAY=20MO
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every Thursday in March, forever" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :yearly,
					bymonth: [3],
					byweekday: [:thursday]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=YEARLY;INTERVAL=1;WKST=MO;BYMONTH=3;BYDAY=TH
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "every Friday the 13th, forever" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					bymonthday: [13],
					byweekday: [:friday]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;WKST=MO;BYMONTHDAY=13;BYDAY=FR
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "US Presidential Election Day" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :yearly,
					interval: 4,
					bymonth: [11],
					byweekday: [:tuesday],
					bymonthday: [2, 3, 4, 5, 6, 7, 8]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=YEARLY;INTERVAL=4;WKST=MO;BYMONTH=11;BYMONTHDAY=2,3,4,5,6,7,8;BYDAY=TU
			"""
			assert ical == ICal.serialize(ruleset)
		end

		test "the 2nd to last weekday of the month" do
			ruleset = %RuleSet{
				rrules: [%Rule{
					dtstart: @dtstart,
					freq: :monthly,
					byweekday: [:monday, :tuesday, :wednesday, :thursday, :friday],
					bysetpos: [-2]
				}]
			}

			ical = """
			DTSTART;TZID=Etc/UTC:19970902T090000Z
			RRULE:FREQ=MONTHLY;INTERVAL=1;WKST=MO;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2
			"""
			assert ical == ICal.serialize(ruleset)
		end
	end
end
