module SmartAnswer::Calculators
	class PlanAdoptionLeave

		attr_reader :formatted_match_date, :formatted_arrival_date, :formatted_start_date

		def initialize(options = {})
			@match_date = Date.parse(options[:match_date])
			@formatted_match_date = formatted_date(@match_date) 
			@arrival_date = Date.parse(options[:arrival_date])
			@formatted_arrival_date = formatted_date(@arrival_date) 
			@start_date = get_start_date(options[:start_date])
			@formatted_start_date = formatted_date(@start_date)
		end

		def formatted_date(dt)
			dt.strftime("%d %B %Y")
		end

		def format_date_range(range)
	  	first = formatted_date(range.first)
	  	last = formatted_date(range.last)
	  	(first + " - " + last)
	  end 

		def get_start_date(dtstr)
			num = dtstr.split('_')[1].to_i
			dayweek = dtstr.split('_')[0]
			num = (dayweek == 'weeks' ? num * 7 : num)
			days_ago = num.days.ago(@match_date)
		end

		def distance_start(dtstr)
			dtstr.split('_')[1].to_i.to_s + " " + dtstr.split('_')[0]
		end

		## borrowed methods

		def earliest_start
	    @arrival_date - 14
	  end

		def expected_week
      sunday = @match_date - @match_date.wday
      saturday = sunday + 6
      sunday..saturday
	  end

	  def qualifying_week
	    expected_week && weeks_later(expected_week, -1)
	  end

	  # def earliest_start
	  #   expected_week && expected_week_of_childbirth.first - 11 * 7
	  # end

		def period_of_ordinary_leave
      @start_date .. @start_date + 26 * 7
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