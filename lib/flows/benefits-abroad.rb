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
end

multiple_choice :question_6 do
  option :eea_switzerland_gibraltar => :answer_8
  option :jersey_etc => :answer_9
  option :none_of_the_above => :answer_10
end

multiple_choice :question_7 do
  option :eea_switzerland_gibraltar => :question_8
  option :other => :answer_11
end

multiple_choice :question_8 do
  option :yes => :answer_12
  option :no => :answer_11
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
