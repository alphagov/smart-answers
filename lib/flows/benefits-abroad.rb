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
end

multiple_choice :question_5 do
  option :jsa => :question_6
  option :pension => :answer_7
  option :wfp => :question_7
end

multiple_choice :question_6 do
end

multiple_choice :question_7 do
end

outcome :answer_1
outcome :answer_2
outcome :answer_7