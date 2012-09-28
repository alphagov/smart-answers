module SmartAnswer::Calculators
	class PlanPaternityLeave

		attr_reader :formatted_due_date, :formatted_start_date

		def initialize(options = {})
			@due_date = due_date = Date.parse(options[:due_date])
			@formatted_due_date = formatted_date(@due_date) 
			@start_date = start = get_start_date(options[:start_date])
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

	  def format_date_range(range)
	  	first = formatted_date(range.first)
	  	last = formatted_date(range.last)
	  	(first + " - " + last)
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
	    additional_leave_start = @due_date + 19 * 7
	    additional_leave_end = additional_leave_start + 26 * 7 -1
	    additional_leave_start .. additional_leave_end
	  end
	  
	  private
	    def weeks_later(range, weeks)
	      (range.first + weeks * 7) .. (range.last + weeks * 7)
	    end

	end
end