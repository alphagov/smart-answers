satisfies_need "B91"
section_slug "work"
subsection_slug ""
status :draft

multiple_choice :have_uk_passport? do
  option :yes => :is_british_citizen_with_passport?
  option :no => :is_british_citizen_without_passport?
end

multiple_choice :is_british_citizen_with_passport? do
  option :yes => :is_eligible
  option :no => :has_right_of_abode?
end

multiple_choice :is_british_citizen_without_passport? do
  option :yes => :is_eligible_need_evidence
  option :no => :has_right_of_abode?
end


multiple_choice :has_right_of_abode? do
  option :yes => :is_eligible
  option :no => :more_questions
end


outcome :is_eligible
outcome :is_eligible_need_evidence
outcome :more_questions