status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

## Q1
multiple_choice :what_type_of_leave? do
  option :maternity => :baby_due_date_maternity?
  option :paternity => :leave_or_pay_for_adoption?
end

## QM1
date_question :baby_due_date_maternity? do
  next_node :employment_contract?
end

## QM2
multiple_choice :employment_contract? do
  option :yes => :date_leave_starts?
  # option :no => # result 3M
end

## QM3
date_question :date_leave_starts? do
  next_node :did_the_employee_work_for_you?
end

## QM4
multiple_choice :did_the_employee_work_for_you? do
  option :yes => :is_the_employee_on_your_payroll? 
#  option :no => 
end

## QM5
multiple_choice :is_the_employee_on_your_payroll? do
  option :yes => :employees_average_weekly_earnings?
end

## QM6
money_question :employees_average_weekly_earnings? do
end

## QP0
multiple_choice :leave_or_pay_for_adoption? do
end
