module SmartAnswer
  class AgeRelatedAllowanceChooser
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

    def initialize(date_and_figures = {})
      @personal_allowance = date_and_figures[:personal_allowance]
      @over_65_allowance = date_and_figures[:over_65_allowance]
      @over_75_allowance = date_and_figures[:over_75_allowance]
    end

    def age_on_fifth_april(birth_date)
      fifth_april = Date.new(Date.today.year, 4, 5)
      age_on_fifth_april = fifth_april.year - birth_date.year
    end

    def get_age_related_allowance(birth_date)
      age_for_chooser = age_on_fifth_april(birth_date)
      if age_for_chooser < 65
        age_related_allowance = @personal_allowance
      elsif age_for_chooser < 75
        age_related_allowance = @over_65_allowance
      else
        age_related_allowance = @over_75_allowance
      end
    end
  end
end
