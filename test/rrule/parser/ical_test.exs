defmodule RRule.Parser.ICalTest do
	use ExUnit.Case
	alias RRule.Parser.ICal

	describe "parse/1" do
		test "daily with 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970902T090000
			RRULE:FREQ=DAILY;COUNT=10
			"""

			{:ok, ruleset} = ICal.parse(ical)
			assert ruleset.dtstart.time_zone == "US/Eastern"

			[rrule] = ruleset.rrules
			assert rrule.freq == :daily
			assert rrule.count == 10
		end

		test "monthly for 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970902T090000
			RRULE:FREQ=MONTHLY;COUNT=10
			"""

			{:ok, ruleset} = ICal.parse(ical)
			assert ruleset.dtstart.time_zone == "US/Eastern"

			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.count == 10
		end

		test "weekly for 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970902T090000
			RRULE:FREQ=WEEKLY;COUNT=10
			"""

			{:ok, ruleset} = ICal.parse(ical)
			assert ruleset.dtstart.time_zone == "US/Eastern"

			[rrule] = ruleset.rrules
			assert rrule.freq == :weekly
			assert rrule.count == 10
		end

		test "every 5 weeks on Monday and Friday until 2013-01-30 at 11pm" do
			ical = """
			DTSTART:20120201T093000Z
			RRULE:FREQ=WEEKLY;INTERVAL=5;UNTIL=20130130T230000Z;BYDAY=MO,FR
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :weekly
			assert rrule.interval == 5
			assert rrule.until == DateTime.new!(~D[2013-01-30], ~T[23:00:00])
			assert rrule.byweekday == [:monday, :friday]
		end

		test "every other week on Monday, Wednesday and Friday until December 24, 1997, but starting on Tuesday, September 2, 1997" do
			ical = """
			DTSTART;TZID=US-Eastern:19970902T090000
			RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :weekly
			assert rrule.interval == 2
			assert rrule.until == DateTime.new!(~D[1997-12-24], ~T[00:00:00])
			assert rrule.wkst == :sunday
			assert rrule.byweekday == [:monday, :wednesday, :friday]
		end

		test "every other month on the 1st and last Sunday of the month for 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970907T090000
			RRULE:FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.interval == 2
			assert rrule.count == 10
			assert rrule.byweekday == [[1, :sunday], [-1, :sunday]]
		end

		test "monthly on the second to last Monday of the month for 6 months" do
			ical = """
			DTSTART;TZID=US-Eastern:19970922T090000
			RRULE:FREQ=MONTHLY;COUNT=6;BYDAY=-2MO
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.count == 6
			assert rrule.byweekday == [[-2, :monday]]
		end

		test "monthly on the third to the last day of the month forever" do
			ical = """
			DTSTART;TZID=US-Eastern:19970928T090000
			RRULE:FREQ=MONTHLY;BYMONTHDAY=-3
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.bymonthday == [-3]
		end

		test "monthly on the 2nd and 15th of the month for 10 occurrences" do
			ical = """
			DTSTART;TZID=US/Eastern:19970902T090000
			RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=2,15
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.count == 10
			assert rrule.bymonthday == [2, 15]
		end

		test "monthly on the first and last day of the month for 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970930T090000
			RRULE:FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.count == 10
			assert rrule.bymonthday == [-1, 1]
		end

		test "every 18 months on the 10th thru 15th of the month for 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970910T090000
			RRULE:FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.interval == 18
			assert rrule.count == 10
			assert rrule.bymonthday == [10, 11, 12, 13, 14, 15]
		end

		test "every 3rd year on the 1st, 100th and 200th day for 10 occurrences" do
			ical = """
			DTSTART;TZID=US-Eastern:19970101T090000
			RRULE:FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :yearly
			assert rrule.interval == 3
			assert rrule.count == 10
			assert rrule.byyearday == [1, 100, 200]
		end

		test "every 20th Monday of the year, forever" do
			ical = """
			DTSTART;TZID=US-Eastern:19970519T090000
			RRULE:FREQ=YEARLY;BYDAY=20MO
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :yearly
			assert rrule.byweekday == [[20, :monday]]
		end

		test "every Thursday in March, forever" do
			ical = """
			DTSTART;TZID=US-Eastern:19970313T090000
			RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=TH
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :yearly
			assert rrule.bymonth == [3]
			assert rrule.byweekday == [:thursday]
		end

		test "every Friday the 13th, forever" do
			ical = """
			DTSTART;TZID=US-Eastern:19970902T090000
			RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.bymonthday == [13]
			assert rrule.byweekday == [:friday]
		end

		test "US Presidential Election Day" do
			ical = """
			DTSTART;TZID=US-Eastern:19961105T090000
			RRULE:FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :yearly
			assert rrule.interval == 4
			assert rrule.bymonth == [11]
			assert rrule.bymonthday == [2, 3, 4, 5, 6, 7, 8]
		end

		test "the 2nd to last weekday of the month" do
			ical = """
			DTSTART;TZID=US-Eastern:19970929T090000
			RRULE:FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2
			"""

			{:ok, ruleset} = ICal.parse(ical)
			[rrule] = ruleset.rrules
			assert rrule.freq == :monthly
			assert rrule.byweekday == [:monday, :tuesday, :wednesday, :thursday, :friday]
			assert rrule.bysetpos == [-2]
		end
	end
end
