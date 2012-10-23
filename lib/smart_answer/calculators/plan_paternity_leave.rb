module SmartAnswer::Calculators
	class PlanPaternityLeave
		include ActionView::Helpers::DateHelper

		attr_reader :formatted_due_date, :formatted_start_date

		def initialize(options = {})
			@due_date = due_date = Date.parse(options[:due_date])
			@formatted_due_date = @due_date.strftime("%A, %d %B %Y")
		end

		def leave_duration(weeks)
			@weeks_to_take = weeks
		end

		def potential_leave
			week_num = (@weeks_to_take == 2 ? 6 : 7)
			@due_date..week_num.weeks.since(@due_date)
		end

		def enter_start_date(entered_start_date)
			@start_date = Date.parse(entered_start_date)
			@formatted_start_date = formatted_date(@start_date)
		end

		def formatted_date(dt)
			dt.strftime("%d %B %Y")
		end

		def format_date_range(range)
	  	first = formatted_date(range.first)
	  	last = formatted_date(range.last)
	  	(first + " to " + last)
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

	  def latest_start
    	@due_date + 8 * 7 - 1
  	end

	  def ordinary_leave_ends
	    anticipated_end = @start_date + 2 * 7 -1
	    if anticipated_end > latest_start
	      latest_start
	    else
	      anticipated_end
	    end
	  end

	  def period_of_potential_ordinary_leave
	    @due_date .. latest_start
	  end

	  def period_of_ordinary_leave
	    @start_date .. ordinary_leave_ends
	  end
	  
	  def period_of_additional_leave
	    additional_leave_start = @due_date + 20 * 7
	    additional_leave_end = additional_leave_start + 26 * 7 -1
	    additional_leave_start .. additional_leave_end
	  end
	  
	  private
	    def weeks_later(range, weeks)
	      (range.first + weeks * 7) .. (range.last + weeks * 7)
	    end

	end
end