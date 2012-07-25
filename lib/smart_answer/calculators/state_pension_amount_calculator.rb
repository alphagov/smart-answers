module SmartAnswer::Calculators
  class StatePensionAmountCalculator
    attr_reader :gender, :dob, :qualifying_years

    def initialize(answers)
      @gender = answers[:gender].to_sym
      @dob = Date.parse(answers[:dob])
      @qualifying_years = answers[:qualifying_years].to_i
    end

    def current_weekly_rate
      107.45
    end

    def years_needed_limit
      {
        male:   Date.parse("6th April 1945"),
        female: Date.parse("6th April 1950")
      }[gender]
    end

    def years_needed_age
      dob < years_needed_limit ? :old : :new
    end

    def years_needed
      {
        male: {
          old: 44,
          new: 30
        },
        female: {
          old: 39,
          new: 44
        }
      }[gender][years_needed_age]
    end

    def current_year
      Date.today.year
    end

    def years_to_pension
      state_pension_year - current_year
    end

    def what_you_get
      qualifying_years / years_needed * current_weekly_rate
    end

    def you_get_future
      (current_weekly_rate * (1.025**years_to_pension)).round(2)
    end

    def state_pension_year
      state_pension_date.year
    end

    def state_pension_age
      state_pension_year - dob.year
    end

    def state_pension_date
      state_pension_dates.find do |p|
        dob >= p[:start_date] and dob <= p[:end_date] and (p[:gender] == gender or :both == p[:gender])
      end[:pension_date]
    end

    def state_pension_dates
      pension_dates_static + pension_dates_dynamic
    end

    def pension_dates_dynamic
      [
        {gender: :female, start_date: Date.new(1890,01,01), end_date: Date.new(1950, 04, 05), pension_date: 60.years.since(dob)},
        {gender: :male,   start_date: Date.new(1890,01,01), end_date: Date.new(1953, 10, 05), pension_date: 65.years.since(dob)},
        {gender: :both,   start_date: Date.new(1954,10,06), end_date: Date.new(1968, 04, 05), pension_date: 66.years.since(dob)},
        {gender: :both,   start_date: Date.new(1969,04,06), end_date: Date.new(1977, 04, 05), pension_date: 67.years.since(dob)},
        {gender: :both,   start_date: Date.new(1978,04,06), end_date: Date.today,             pension_date: 68.years.since(dob)}
      ]
    end

    def pension_dates_static
      YAML.load(File.open("lib/data/state_pension_dates.yml").read)[:pension_dates]
    end
  end
end
