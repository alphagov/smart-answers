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
  
end

## QP0
multiple_choice :leave_or_pay_for_adoption? do
end
