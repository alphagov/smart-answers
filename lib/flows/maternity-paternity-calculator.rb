status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

## Q1
multiple_choice :what_type_of_leave? do
  option :maternity => :baby_due_date_maternity?
  option :paternity => :leave_or_pay_for_adoption?
  option :adoption => :maternity_or_paternity_leave_for_adoption?
end

## QM1
date_question :baby_due_date_maternity? do
  next_node :employment_contract?
end

## QM2
multiple_choice :employment_contract? do
  option :yes => :date_leave_starts?
  option :no => :not_entitled_to_statutory_maternity_leave # R3M
end

## QM3
date_question :date_leave_starts? do
  next_node :did_the_employee_work_for_you?
end

## QM4
multiple_choice :did_the_employee_work_for_you? do
  option :yes => :is_the_employee_on_your_payroll? 
  option :no => :not_entitled_to_statutory_maternity_pay ## R4M
end

## QM5
multiple_choice :is_the_employee_on_your_payroll? do
  option :yes => :employees_average_weekly_earnings?
end

## QM6
money_question :employees_average_weekly_earnings? do
end

## Maternity outcomes
outcome :not_entitled_to_statutory_maternity_leave ## R3M
outcome :not_entitled_to_statutory_maternity_pay ## R4M


## QP0
multiple_choice :leave_or_pay_for_adoption? do
	option :yes => :baby_due_date_paternity?
	option :no => :employee_date_matched_paternity_adoption?
end

## QP1
date_question :baby_due_date_paternity? do
  
end




## QPA1
date_question :employee_date_matched_paternity_adoption? do

end

## QA0
multiple_choice :maternity_or_paternity_leave_for_adoption? do
  option :maternity => :date_of_adoption_match? # QA1
#  option :paternity =>
end

## QA1
date_question :date_of_adoption_match? do
  next_node :date_of_adoption_placement?
end

## QA2
date_question :date_of_adoption_placement? do
  next_node :adoption_employment_contract?
end

## QA3
multiple_choice :adoption_employment_contract? do
  option :yes => :adoption_date_leave_starts?
  option :no => :adoption_not_entitled_to_leave
end

## QA4
date_question :adoption_date_leave_starts? do
  next_node :adoption_did_the_employee_work_for_you?
end

## QA5
multiple_choice :adoption_did_the_employee_work_for_you? do
  option :yes => :adoption_is_the_employee_on_your_payroll?
  option :no => :adoption_not_entitled_to_leave_or_pay
end

## QA7
multiple_choice :adoption_is_the_employee_on_your_payroll? do
  option :yes => :adoption_employees_average_weekly_earnings?
  option :no => :adoption_not_entitled_to_pay
end

## QA8
money_question :adoption_employees_average_weekly_earnings? do
end

outcome :adoption_not_entitled_to_leave
outcome :adoption_not_entitled_to_pay
outcome :adoption_not_entitled_to_leave_or_pay
