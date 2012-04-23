status :published

section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need 2012

multiple_choice :were_you_or_your_partner_born_on_or_before_6_april_1935? do
  option :yes => :did_you_marry_or_civil_partner_before_5_december_2005?
  option :no => :sorry
end

multiple_choice :did_you_marry_or_civil_partner_before_5_december_2005? do
  option :yes => :whats_the_husbands_date_of_birth?
  option :no => :whats_the_highest_earners_date_of_birth?

  calculate :result_strings do
    (responses.last == "yes") ? PhraseList.new(:before_2005) : PhraseList.new(:after_2005)
  end
end

date_question :whats_the_husbands_date_of_birth? do
  to { Date.parse('1 Jan 1896') }
  from { Date.today }

  save_input_as :birth_date 
  next_node :whats_the_husbands_income?
end

date_question :whats_the_highest_earners_date_of_birth? do
  to { Date.parse('1 Jan 1896') }
  from { Date.today }

  save_input_as :birth_date
  next_node :whats_the_highest_earners_income?
end
  
personal_allowance = 8105
over_65_allowance = 10500
over_75_allowance = 10660

age_related_allowance_chooser = AgeRelatedAllowanceChooser.new(
  personal_allowance: personal_allowance,
  over_65_allowance: over_65_allowance,
  over_75_allowance: over_75_allowance)

calculator = MarriedCouplesAllowanceCalculator.new(
  maximum_mca: 7705, 
  minimum_mca: 2960, 
  income_limit: 25400, 
  personal_allowance: personal_allowance)

money_question :whats_the_husbands_income? do
  calculate :allowance do
    age_related_allowance = age_related_allowance_chooser.get_age_related_allowance(Date.parse(birth_date))
    calculator.calculate_allowance(age_related_allowance, responses.last)
  end

  next_node :done
end

money_question :whats_the_highest_earners_income? do
  calculate :allowance do
    age_related_allowance = age_related_allowance_chooser.get_age_related_allowance(Date.parse(birth_date))
    calculator.calculate_allowance(age_related_allowance, responses.last)
  end

  next_node :done
end

outcome :done
outcome :sorry