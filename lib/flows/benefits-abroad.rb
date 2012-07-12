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
  option :maternity => :are_you_moving_to_a_country
  option :child_benefits => :question_13
  option :ssp => :question_15
  option :tax_credits => :question_18
  option :esa => :question_25
  option :industrial_injuries => :question_27
  option :disability => :question_29
  option :bereavement => :question_35
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
multiple_choice :are_you_moving_to_a_country do
  option :eea => :question_10
  option :not_eea => :question_12
end

multiple_choice :question_10 do
end

multiple_choice :question_12 do
end

multiple_choice :question_13 do
end

multiple_choice :question_15 do
end

multiple_choice :question_18 do
end

multiple_choice :question_25 do
end

multiple_choice :question_27 do
end

multiple_choice :question_29 do
end

multiple_choice :question_35 do
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
