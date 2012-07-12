satisfies_need "9999"
status :draft
section_slug "money-and-tax"

# Q1
multiple_choice :have_you_told_jobcentre_plus do
  option :yes => :have_you_paid_ni_in_the_uk
  option :no => :answer_1
end

# Q2
multiple_choice :have_you_paid_ni_in_the_uk do
  option :yes => :certain_countries_or_specific_benefits
  option :no => :answer_2
end

# Q3
multiple_choice :certain_countries_or_specific_benefits do
  option :certain_countries => :are_you_moving_to_q4
  option :specific_benefits => :which_benefit_would_you_like_to_claim
end

# Q4
multiple_choice :are_you_moving_to_q4 do
  option :eea_or_switzerland => :answer_3
  option :gibraltar => :answer_4
  option :other_listed => :answer_5
  option :none_of_the_above => :answer_6
end

# Q5
multiple_choice :which_benefit_would_you_like_to_claim do
  option :jsa => :are_you_moving_to_q6
  option :pension => :answer_7
  option :wfp => :are_you_moving_to_q7
  option :maternity => :are_you_moving_to_a_country_q9
  option :child_benefits => :moving_to
  option :ssp => :are_you_moving_to_a_country_q15
  option :tax_credits => :claiming_tax_credits_or_eligible
  option :esa => :claiming_esa_abroad_for
  option :industrial_injuries => :claiming_iidb
  option :disability => :getting_any_allowances
  option :bereavement => :eligible_for_the_following
end

# Q6
multiple_choice :are_you_moving_to_q6 do
  option :eea_switzerland_gibraltar => :answer_8
  option :jersey_etc => :answer_9
  option :none_of_the_above => :answer_10
end

# Q7
multiple_choice :are_you_moving_to_q7 do
  option :eea_switzerland_gibraltar => :already_qualify_for_wfp_in_the_uk
  option :other => :answer_11
end

# Q8
multiple_choice :already_qualify_for_wfp_in_the_uk do
  option :yes => :answer_12
  option :no => :answer_11
end

# Q9
multiple_choice :are_you_moving_to_a_country_q9 do
  option :eea => :uk_employer
  option :not_eea => :employer_paying_ni
end

# Q10
multiple_choice :uk_employer do
  option :yes => :eligible_for_maternity_pay
  option :no => :answer_13
end

#Q11
multiple_choice :eligible_for_maternity_pay do
  option :yes => :answer_14
  option :no => :answer_13
end

# Q12
multiple_choice :employer_paying_ni do
  option :yes => :eligible_for_maternity_pay
  option :no => :answer_15
end

# Q13
multiple_choice :moving_to do
  option :barbados_canada_israel => :answer_16
  option :eea_or_switzerland => :paying_nics_and_receiving_uk_benefits
  option :other => :answer_18
end

# Q14
multiple_choice :paying_nics_and_receiving_uk_benefits do
  option :yes => :answer_17
  option :no => :answer_18
end

# Q15
multiple_choice :are_you_moving_to_a_country_q15 do
  option :in_eea => :working_for_a_uk_employer
  option :outside_eea => :employer_paying_uk_nics
end

# Q16
multiple_choice :working_for_a_uk_employer do
  option :yes => :answer_19
  option :no => :answer_20
end

# Q17
multiple_choice :employer_paying_uk_nics do
  option :yes => :answer_19
  option :no => :answer_20
end

# Q18
multiple_choice :claiming_tax_credits_or_eligible do
  option :no => :answer_20
  option :yes => :you_or_partner
end

# Q19
multiple_choice :you_or_partner do
end

# Q25
multiple_choice :claiming_esa_abroad_for do
end

# Q27
multiple_choice :claiming_iidb do
end

# Q29
multiple_choice :getting_any_allowances do
end

# Q35
multiple_choice :eligible_for_the_following do
end

outcome :answer_1
outcome :answer_2
outcome :answer_3
outcome :answer_4
outcome :answer_5
outcome :answer_6
outcome :answer_7
outcome :answer_8
outcome :answer_9
outcome :answer_10
outcome :answer_11
outcome :answer_12
outcome :answer_13
outcome :answer_14
outcome :answer_15
outcome :answer_16
outcome :answer_17
outcome :answer_18
outcome :answer_19
outcome :answer_20
