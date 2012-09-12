status :draft
section_slug "money-and-tax"
subsection_slug "pension"
satisfies_need "99999"

multiple_choice :work_in_uk? do
  option :yes => :self_employed?
  option :no => :not_enrolled
end

multiple_choice :self_employed? do
  option :yes => :not_enrolled_self_employed
  option :no => :workplace_pension?
end

multiple_choice :workplace_pension? do
  option :yes => :continue_to_pay
  option :no => :how_old?
end

multiple_choice :how_old? do
  option :between_16_21 => :annual_earnings?
  option :between_22_sp => :annual_earnings2?
  option :state_pension_age => :annual_earnings?
end

multiple_choice :annual_earnings? do
  option :up_to_5k => :not_enrolled_with_options
  option :more_than_5k => :not_enrolled_opt_in
end

multiple_choice :annual_earnings2? do
  option :up_to_5k => :not_enrolled_with_options
  option :between_5k_8k => :not_enrolled_opt_in
  option :more_than_8k => :one_of_the_following?
  option :varies => :not_enrolled_income_varies
end

multiple_choice :one_of_the_following? do
  option :armed_forces => :not_enrolled_mod
  option :agency => :enrolled_agency
  option :several_employers => :enrolled_several
  option :overseas_company => :enrolled_overseas
  option :contract => :enrolled_contract
  option :office_holder => :not_enrolled_office
  option :none => :enrolled
end

outcome :not_enrolled
outcome :not_enrolled_self_employed
outcome :continue_to_pay
outcome :not_enrolled_with_options
outcome :not_enrolled_opt_in
outcome :not_enrolled_income_varies
outcome :not_enrolled_mod
outcome :enrolled_agency
outcome :enrolled_several
outcome :enrolled_overseas
outcome :enrolled_contract
outcome :not_enrolled_office
outcome :enrolled