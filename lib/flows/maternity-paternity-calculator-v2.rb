status :draft
satisfies_need "100990"



## Q1
multiple_choice :what_type_of_leave? do
  save_input_as :leave_type
  option :maternity => :baby_due_date_maternity?
  option :paternity => :leave_or_pay_for_adoption?
  option :adoption => :taking_paternity_leave_for_adoption?
end


use_shared_logic ("adoption-calculator-v2")
use_shared_logic ("paternity-calculator-v2")
use_shared_logic ("maternity-calculator-v2")
