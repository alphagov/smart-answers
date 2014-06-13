module SmartAnswer::Calculators
  class StatePensionTopupDataQueryV2

    attr_reader :data

   def initialize
     @data = self.class.age_and_rates_data
    end

    def age_and_rates(age)
      data['age_and_rates'][age]
    end

    def self.age_and_rates_data
      @age_and_rates_data ||= YAML.load_file(Rails.root.join("lib", "data", "pension_top_up_data.yml"))
    end

    def money_rate_cost(age,weekly_amount)
      total = age_and_rates(age) * weekly_amount.to_f
      total_money = SmartAnswer::Money.new(total)
    end

    def date_difference_in_years(date_of_birth,date_limit)
      dob = Date.parse(date_of_birth)
      years = date_limit.year - dob.year
      if (date_limit.month < dob.month) || ((date_limit.month == dob.month) && (date_limit.day < date_of_birth.day))
        years = years - 1
      end
      years
    end

  end
end
