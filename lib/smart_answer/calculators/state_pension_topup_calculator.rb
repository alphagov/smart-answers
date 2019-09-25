module SmartAnswer::Calculators
  class StatePensionTopupCalculator
    include ActiveModel::Model

    FEMALE_YOUNGEST_DOB = Date.parse("1953-04-05")
    MALE_YOUNGEST_DOB = Date.parse("1951-04-05")
    TOPUP_START_DATE = Date.parse("2015-10-12")
    TOPUP_END_DATE = Date.parse("2017-04-05")
    FEMALE_RETIREMENT_AGE = 62
    MALE_RETIREMENT_AGE = 65

    attr_accessor :date_of_birth
    attr_accessor :gender
    attr_accessor :weekly_amount

    def initialize(attributes = {})
      super
      @gender ||= "female"
    end

    def valid_whole_number_weekly_amount?
      (weekly_amount.to_f % 1).zero?
    end

    def valid_weekly_amount_in_range?
      (1..25).include?(weekly_amount.to_f)
    end

    def lump_sum_and_age
      return [] if too_young?

      rows = []
      dob = leap_year_birthday?(date_of_birth) ? date_of_birth + 1.day : date_of_birth
      age = age_at_date(dob, Date.today)
      (topup_start_year..TOPUP_END_DATE.year).each do |_|
        break if birthday_after_topup_end?(dob, age)

        rows << { amount: lump_sum_amount(age, weekly_amount), age: age } if age >= retirement_age(gender)
        age += 1
      end
      if (TOPUP_END_DATE.year == Date.today.year) && (dob.month < 5) && (birthday(dob) > Date.today) && !birthday_after_topup_end?(dob, age)
        rows << { amount: lump_sum_amount(age, weekly_amount), age: age } if age >= retirement_age(gender)
      end
      rows
    end

    def topup_start_year
      if Date.today.year > TOPUP_START_DATE.year
        Date.today.year
      else
        TOPUP_START_DATE.year
      end
    end

    def too_young?
      case gender
      when "female"
        date_of_birth > FEMALE_YOUNGEST_DOB
      when "male"
        date_of_birth > MALE_YOUNGEST_DOB
      end
    end

  private

    def retirement_age(gender)
      if gender == "female"
        FEMALE_RETIREMENT_AGE
      elsif gender == "male"
        MALE_RETIREMENT_AGE
      end
    end

    def lump_sum_amount(age, weekly_amount)
      data_query = StatePensionTopupDataQuery.new
      total = if data_query.age_and_rates(age)
                data_query.age_and_rates(age) * weekly_amount.to_f
              else
                0
              end
      SmartAnswer::Money.new(total)
    end

    def birthday_after_topup_end?(dob, age)
      birthday = Date.new(TOPUP_END_DATE.year, dob.month, dob.day)
      age_at_topup_end = age_at_date(dob, TOPUP_END_DATE)
      (age > age_at_topup_end) && (birthday >= TOPUP_END_DATE)
    end

    def birthday(dob)
      Date.new(Date.today.year, dob.month, dob.day)
    end

    def age_at_date(dob, date)
      years = date.year - dob.year
      birthday = Date.new(date.year, dob.month, dob.day)
      if date < birthday
        years = years - 1
      end
      years
    end

    def leap_year_birthday?(dob)
      Date.new(dob.year).leap? && (dob.month == 2 && dob.day == 29)
    end
  end
end
