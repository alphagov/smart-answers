module SmartAnswer
	class AgeRelatedAllowanceChooser

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