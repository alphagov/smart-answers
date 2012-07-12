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
  option :child_benefits => :moving_to
  option :ssp => :moving_country
  option :tax_credits => :claiming_tax_credits_or_eligible
  option :esa => :claiming_esa_abroad_for
  option :industrial_injuries => :claiming_iidb
  option :disability => :getting_any_allowances
  option :bereavement => :eligible_for_the_following
end

multiple_choice :question_6 do
end

multiple_choice :question_7 do
end

multiple_choice :question_9 do
  option :eea => :uk_employer
  option :not_eea => :employer_paying_ni
end

multiple_choice :uk_employer do
end

multiple_choice :employer_paying_ni do
end

multiple_choice :moving_to do
end

multiple_choice :moving_country do
end

multiple_choice :claiming_tax_credits_or_eligible do
end

multiple_choice :claiming_esa_abroad_for do
end

multiple_choice :claiming_iidb do
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
