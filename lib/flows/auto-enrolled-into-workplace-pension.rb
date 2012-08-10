status :draft
section_slug "money-and-tax"
subsection_slug "pension"
satisfies_need "99999"

multiple_choice :work_in_uk? do
  option :yes => :self_employed?
  option :no => :not_enrolled
end

multiple_choice :self_employed? do
end

outcome :not_enrolled