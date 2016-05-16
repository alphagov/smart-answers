module SmartAnswer::Calculators
  class PersonalAllowanceCalculator
    # created for married couples allowance calculator.
    # this could be extended for use across smart answers
    # and/or GOV.UK

    # if you earn over the income limit for age-related allowance
    # then your age-related allowance is reduced by £1 for every £2
    # you earn over the limit until the personal allowance is reached,
    # at which point reduction stops (the basic personal allowance is not
    # reduced)

    # in addition, if you earn over the income limit for personal allowance
    # your personal allwowance is reduced in the same way. In the year 2012-13
    # this limit was £100,000 so no need to include it in this calculation
    # as we've already gone way over where it would make a difference to your MCA.

    # so this class could be extended so that it returns the personal allowance
    # you are entitled to based on your age and income.

    def age_on_fifth_april(birth_date)
      fifth_april = Date.new(Date.today.year, 4, 5)
      SmartAnswer::DateOfBirth.new(birth_date).age(on: fifth_april)
    end

    def age_related_allowance(birth_date)
      if Date.today > Date.parse('2013-04-05')
        if birth_date > Date.parse('1948-04-05')
          personal_allowance
        elsif birth_date > Date.parse('1938-04-05')
          higher_allowance_1
        else
          higher_allowance_2
        end
      else
        age = age_on_fifth_april(birth_date)
        if age < 65
          personal_allowance
        elsif age < 75
          higher_allowance_1
        else
          higher_allowance_2
        end
      end
    end

    def personal_allowance
      rates.personal_allowance
    end

    def income_limit_for_personal_allowances
      rates.income_limit_for_personal_allowances
    end

  private

    def higher_allowance_1
      rates.higher_allowance_1
    end

    def higher_allowance_2
      rates.higher_allowance_2
    end

    def rates
      @rates ||= RatesQuery.from_file('personal_allowance').rates
    end
  end
end
