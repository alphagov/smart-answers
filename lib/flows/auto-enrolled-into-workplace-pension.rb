status :draft
section_slug "money-and-tax"
subsection_slug "pension"
satisfies_need "99999"

multiple_choice :work_in_uk? do
  option :yes => :self_employed?
  option :no => :not_enrolled
end

multiple_choice :self_employed? do
  option :yes => :not_enrolled
  option :no => :workplace_pension?
end

multiple_choice :workplace_pension? do
  option :yes => :continue_to_pay
  option :no => :how_old?
end

multiple_choice :how_old? do
end

outcome :not_enrolled
outcome :continue_to_pay