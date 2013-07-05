status :published
satisfies_need "2483"

multiple_choice :work_in_uk? do
  option :yes => :workplace_pension?
  option :no => :not_enrolled
end

multiple_choice :workplace_pension? do
  option :yes => :continue_to_pay
  option :no => :how_many_people?
end

value_question :how_many_people? do
  calculate :num_employees do
    num = Integer(responses.last)
    raise SmartAnswer::InvalidResponse if num < 1 or num > 9999999
    num
  end

  calculate :small_company do
    if num_employees < 30
      PhraseList.new(:small_company_text)
    else
      ''
    end
  end

  next_node :how_old?
end

multiple_choice :how_old? do
  precalculate :enrollment_date do
    Calculators::WorkplacePensionCalculator.enrollment_date(num_employees)
  end
  precalculate :threshold_weekly_rate do
    Calculators::WorkplacePensionCalculator.new.threshold_weekly_rate
  end
  precalculate :threshold_monthly_rate do
    Calculators::WorkplacePensionCalculator.new.threshold_monthly_rate
  end
  precalculate :threshold_annual_rate do
    Calculators::WorkplacePensionCalculator.new.threshold_annual_rate.round
  end
  precalculate :lel_weekly_rate do
    Calculators::WorkplacePensionCalculator.new.lel_weekly_rate
  end
  precalculate :lel_monthly_rate do
    Calculators::WorkplacePensionCalculator.new.lel_monthly_rate
  end
  precalculate :lel_annual_rate do
    Calculators::WorkplacePensionCalculator.new.lel_annual_rate.round
  end

  option :between_16_21 => :annual_earnings?
  option :between_22_sp => :annual_earnings2?
  option :state_pension_age => :annual_earnings?
end

multiple_choice :annual_earnings? do
  option :up_to_5k => :not_enrolled_with_options
  option :more_than_5k => :not_enrolled_opt_in
end

multiple_choice :annual_earnings2? do
  option :up_to_5k => :not_enrolled_with_options
  option :between_5k_9k => :not_enrolled_opt_in
  option :more_than_9k => :one_of_the_following?
  option :varies => :not_enrolled_income_varies
end

multiple_choice :one_of_the_following? do
  option :armed_forces => :not_enrolled_mod
  option :agency => :enrolled_agency
  option :several_employers => :enrolled_several
  option :overseas_company => :enrolled_overseas
  option :contract => :enrolled_contract
  option :office_holder => :not_enrolled_office
  option :carer => :not_enrolled_carer
  option :foreign_national => :enrolled_foreign_national
  option :none => :enrolled
end

outcome :not_enrolled #A1
outcome :continue_to_pay #A2
outcome :not_enrolled_with_options #A4
outcome :not_enrolled_opt_in #A5
outcome :not_enrolled_income_varies #A6
outcome :not_enrolled_mod #A7
outcome :enrolled_agency #A8
outcome :enrolled_several #A9
outcome :enrolled_overseas #A10
outcome :enrolled_contract #A11
outcome :not_enrolled_office #A12
outcome :enrolled #A13
outcome :not_enrolled_carer #A14 
outcome :enrolled_foreign_national #A15
