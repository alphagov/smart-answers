satisfies_need "9999"
status :draft
section_slug "money-and-tax"

multiple_choice :question_1 do
  option :yes => :question_2
  option :no => :answer_1
end

multiple_choice :question_2 do
  option :yes => :question_3
  option :no => :answer_2
end

multiple_choice :question_3 do
  option :certain_countries => :question_4
  option :specific_benefits => :question_5
end

multiple_choice :question_4 do
  option :eea_or_switzerland => :answer_3
  option :gibraltar => :answer_4
  option :other_listed => :answer_5
  option :none_of_the_above => :answer_6
end

multiple_choice :question_5 do
  option :jsa => :question_6
  option :pension => :answer_7
  option :wfp => :question_7
  option :maternity => :question_9
  option :child_benefits => :question_13
  option :ssp => :question_15
  option :tax_credits => :question_18
  option :esa => :question_25
  option :industrial_injuries => :question_27
  option :disability => :getting_any_allowances
  option :bereavement => :eligible_for_the_following
end

multiple_choice :question_6 do
end

multiple_choice :question_7 do
end

multiple_choice :question_9 do
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

multiple_choice :getting_any_allowances do
end

multiple_choice :eligible_for_the_following do
end

outcome :answer_1
outcome :answer_2
outcome :answer_3
outcome :answer_4
outcome :answer_5
outcome :answer_6
outcome :answer_7
