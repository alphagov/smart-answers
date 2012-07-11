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
end

outcome :answer_1
outcome :answer_2