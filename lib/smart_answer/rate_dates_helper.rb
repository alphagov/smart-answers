module SmartAnswer
  module RateDatesHelper
    def last_year_text(rates_file)
      "#{last_year(rates_file)[:start_date].strftime('%B %Y')} to #{last_year(rates_file)[:end_date].strftime('%B %Y')}"
    end

    def last_year_end_text(rates_file)
      last_year(rates_file)[:end_date].strftime("%B %Y").to_s
    end

    def this_year_living_wage_min_age(rates_file)
      this_year(rates_file)[:living_wage_min_age]
    end

    def this_year(rates_file)
      data = SmartAnswer::Calculators::RatesQuery.from_file(rates_file)
      data.current_period
    end

    def last_year(rates_file)
      data = SmartAnswer::Calculators::RatesQuery.from_file(rates_file)
      data.previous_period
    end
  end
end
