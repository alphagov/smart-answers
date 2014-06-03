module SmartAnswer::Calculators
  class MaternityBenefitsCalculatorV2 < BirthCalculator
    def test_period
      period_start = qualifying_week.first - 51.weeks
      period_end = expected_week.first - 1.day
      period_start..period_end
    end

    def eleven_weeks
      11.weeks.ago(@due_date)
    end

    def smp_rate
      if due_date_before_7th_april_2013?
        135.45
      elsif due_date_before_6th_april_2014?
        136.78
      else
        138.18
      end
    end

    def ma_rate
      if due_date_before_7th_april_2013?
        135.45
      elsif due_date_before_6th_april_2014?
        136.78
      else
        138.18
      end
    end

    def smp_lel
      if due_date_before_14th_july_2013?
        107
      elsif due_date_before_6th_april_2014?
        109
      else
        111
      end
    end

    private

    def due_date_before_7th_april_2013?
      @due_date < Date.parse("7th April 2013")
    end

    def due_date_before_14th_july_2013?
      @due_date < Date.parse("14th July 2013")
    end

    def due_date_before_6th_april_2014?
      @due_date < Date.parse("6th April 2014")
    end
  end
end
