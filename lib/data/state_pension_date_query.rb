StatePensionDate = Struct.new(:gender, :start_date, :end_date, :pension_date) do
  def match?(dob, sex)
    same_gender?(sex) && born_in_range?(dob)
  end

  def same_gender?(sex)
    gender == sex || :both == gender
  end

  def born_in_range?(dob)
    dob >= start_date && dob <= end_date
  end
end

StatePensionDateQuery = Struct.new(:dob, :gender) do
  def self.find(dob, gender)
    state_pension_query = new(dob, gender)
    state_pension_query.find_date
  end

  def self.pension_credit_date(dob)
    # Pension credit age calculation for all genders is equivalent
    # to the state pension date calculation for women
    new(dob, :female).find_date
  end

  def self.bus_pass_qualification_date(dob)
    pension_credit_date(dob)
  end

  def find_date
    static_result = run(pension_dates_static)
    if static_result
      static_result.pension_date
    else
      result = run(pension_dates_dynamic)
      adjust_when_dob_is_29february(result.pension_date)
    end
  end

  def run(pension_dates)
    pension_dates.find {|p| p.match?(dob, gender)}
  end

  # Handle the case where the person's d.o.b. is 29th Feb
  # on a leap year and that the pension eligibility date falls
  # on a non-leap year and when dob falls into the dynamic date group.
  # ActiveSupport will adjust the date, but the calculation
  # should adjust to the 1st March according to DWP rules.
  def adjust_when_dob_is_29february(date)
    date += 1 if leap_year_date?(dob) && !leap_year_date?(date)
    date
  end

  def leap_year_date?(date)
    date.month == 2 && date.day == 29
  end

  def pension_dates_dynamic
    [
      StatePensionDate.new(:female, Date.new(1890, 1, 1), Date.new(1950, 4, 5), 60.years.since(dob)),
      StatePensionDate.new(:male, Date.new(1890, 1, 1), Date.new(1953, 12, 5), 65.years.since(dob)),
      StatePensionDate.new(:both, Date.new(1954, 10, 6), Date.new(1960, 4, 5), 66.years.since(dob)),
      StatePensionDate.new(:both, Date.new(1960, 4, 6), Date.new(1960, 5, 5), 66.years.since(dob) + 1.month),
      StatePensionDate.new(:both, Date.new(1960, 5, 6), Date.new(1960, 6, 5), 66.years.since(dob) + 2.months),
      StatePensionDate.new(:both, Date.new(1960, 6, 6), Date.new(1960, 7, 5), 66.years.since(dob) + 3.months),
      StatePensionDate.new(:both, Date.new(1960, 7, 6), Date.new(1960, 8, 5), 66.years.since(dob) + 4.months),
      StatePensionDate.new(:both, Date.new(1960, 8, 6), Date.new(1960, 9, 5), 66.years.since(dob) + 5.months),
      StatePensionDate.new(:both, Date.new(1960, 9, 6), Date.new(1960, 10, 5), 66.years.since(dob) + 6.months),
      StatePensionDate.new(:both, Date.new(1960, 10, 6), Date.new(1960, 11, 5), 66.years.since(dob) + 7.months),
      StatePensionDate.new(:both, Date.new(1960, 11, 6), Date.new(1960, 12, 5), 66.years.since(dob) + 8.months),
      StatePensionDate.new(:both, Date.new(1960, 12, 6), Date.new(1961, 1, 5), 66.years.since(dob) + 9.months),
      StatePensionDate.new(:both, Date.new(1961, 1, 6), Date.new(1961, 2, 5), 66.years.since(dob) + 10.months),
      StatePensionDate.new(:both, Date.new(1961, 2, 6), Date.new(1961, 3, 5), 66.years.since(dob) + 11.months),
      StatePensionDate.new(:both, Date.new(1961, 3, 6), Date.new(1977, 4, 5), 67.years.since(dob)),
      StatePensionDate.new(:both, Date.new(1978, 4, 6), Date.today + 1, 68.years.since(dob))
    ]
  end

  def pension_dates_static
    YAML.load_file(Rails.root.join("lib", "data", "state_pension_dates.yml"))
  end
end
