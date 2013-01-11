status :published
satisfies_need 2012

multiple_choice :were_you_or_your_partner_born_on_or_before_6_april_1935? do
  option :yes => :did_you_marry_or_civil_partner_before_5_december_2005?
  option :no => :sorry
end

multiple_choice :did_you_marry_or_civil_partner_before_5_december_2005? do
  save_input_as :married_before_05_12_2005
  option :yes => :whats_the_husbands_date_of_birth?
  option :no => :whats_the_highest_earners_date_of_birth?
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

age_related_allowance_chooser = Calculators::AgeRelatedAllowanceChooser.new(
  personal_allowance: personal_allowance,
  over_65_allowance: over_65_allowance,
  over_75_allowance: over_75_allowance)

calculator = Calculators::MarriedCouplesAllowanceCalculator.new(
  maximum_mca: 7705,
  minimum_mca: 2960,
  income_limit: 25400,
  personal_allowance: personal_allowance)

money_question :whats_the_husbands_income? do
  calculate :income do
    responses.last
  end
  calculate :age_related_allowance do
    age_related_allowance_chooser.get_age_related_allowance(Date.parse(birth_date))
  end
  calculate :allowance do
    if responses.last <= 24500
      calculator.calculate_allowance(age_related_allowance, responses.last)
    end
  end

  next_node do |response|
    if response > 24500
      :are_you_paying_a_pension?
    else
      :husband_done
    end
  end
end

money_question :whats_the_highest_earners_income? do
  calculate :income do
    responses.last
  end
  calculate :age_related_allowance do
    age_related_allowance_chooser.get_age_related_allowance(Date.parse(birth_date))
  end
  calculate :allowance do
    if responses.last <= 24500
      calculator.calculate_allowance(age_related_allowance, responses.last)
    end
  end

  next_node do |response|
    if response > 24500
      :are_you_paying_a_pension?
    else
      :highest_earner_done
    end
  end
end

multiple_choice :are_you_paying_a_pension? do
  option :yes => :total_pension_and_annuities?
  option :no => :gift_aid_payments?
end

money_question :total_pension_and_annuities? do
  calculate :gross_pension_contributions do
    raise SmartAnswer::InvalidResponse if responses.last < 0
    responses.last
  end
  next_node :tax_relief_pension_payments?
end

money_question :tax_relief_pension_payments? do
  calculate :net_pension_contributions do
    raise SmartAnswer::InvalidResponse if responses.last < 0
    responses.last
  end
  next_node :gift_aid_payments?
end

money_question :gift_aid_payments? do
  calculate :gift_aid_contributions do
    raise SmartAnswer::InvalidResponse if responses.last < 0
    responses.last
  end
 
  calculate :allowance do
    he_income = calculator.calculate_high_earner_income(income: income,
                                                    gross_pension_contributions: gross_pension_contributions,
                                                    net_pension_contributions: net_pension_contributions,
                                                    gift_aid_contributions: gift_aid_contributions)
    calculator.calculate_allowance(age_related_allowance, he_income)
  end
  
  next_node do
    if married_before_05_12_2005 == 'yes'
      :husband_done
    else
      :highest_earner_done
    end
  end
end

outcome :husband_done
outcome :highest_earner_done
outcome :sorry
