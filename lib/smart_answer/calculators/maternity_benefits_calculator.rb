module SmartAnswer::Calculators
	class MaternityBenefitsCalculator < BirthCalculator
		def test_period
			period_start = qualifying_week.first - 51.weeks
			period_end = expected_week.first - 1.day
			period_start..period_end
		end

    def eleven_weeks
      11.weeks.ago(@due_date) + 1.day
    end

    def smp_rate
      if due_date_before_7th_april_2013?
        135.45
      else
        136.78
      end
    end

    def ma_rate
      if due_date_before_7th_april_2013?
        135.45
      else
        136.78
      end
    end

    def smp_LEL
      if due_date_before_14th_july_2013?
        107
      else
        109
      end
    end

    private

    def due_date_before_7th_april_2013?
      @due_date < Date.parse("7th April 2013")
    end

    def due_date_before_14th_july_2013?
      @due_date < Date.parse("14th July 2013")
    end
	end
end
