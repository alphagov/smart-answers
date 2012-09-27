module SmartAnswer::Calculators
	class PlanMaternityLeave

		attr_reader :formatted_due_date, :formatted_start_date

		def initialize(options = {})
			@due_date = Date.parse(options[:due_date])
			@formatted_due_date = formatted_date(@due_date) 
			@start_date = get_start_date(options[:start_date])
			@formatted_start_date = formatted_date(@start_date)
		end

		def formatted_date(dt)
			dt.strftime("%d %B %Y")
		end

		def get_start_date(dtstr)
			num = dtstr.split('_')[1].to_i
			dayweek = dtstr.split('_')[0]
			num = (dayweek == 'weeks' ? num * 7 : num)
			days_ago = num.days.ago(@due_date)
		end

		def distance_start(dtstr)
			dtstr.split('_')[1].to_i.to_s + " " + dtstr.split('_')[0]
		end

		## borrowed methods

		def expected_week_of_childbirth
      sunday = @due_date - @due_date.wday
      saturday = sunday + 6
      sunday..saturday
	  end

	  def qualifying_week
	    expected_week_of_childbirth && weeks_later(expected_week_of_childbirth, -15)
	  end

	  def earliest_start
	    expected_week_of_childbirth && expected_week_of_childbirth.first - 11 * 7
	  end

		def period_of_ordinary_leave
      @start_date .. @start_date + 26 * 7 - 1
	  end

	  def period_of_additional_leave
	    period_of_ordinary_leave && weeks_later(period_of_ordinary_leave, 26)
	  end

	  private
	    def weeks_later(range, weeks)
	      (range.first + weeks * 7) .. (range.last + weeks * 7)
	    end

	end
end