status :draft
section_slug "work"
satisfies_need "9999"

## Q1
multiple_choice :member_of_armed_services? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :armed_services_reason
  end
  option :yes => :no_right_to_apply
  option :no => :are_you_employee?
end

## Q2
multiple_choice :are_you_employee? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :employee_reason
  end
  option :yes => :applied_for_flexible_working?
  option :no => :no_right_to_apply
end

## Q3
multiple_choice :applied_for_flexible_working? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :statutory_request_reason
  end
  option :yes => :no_right_to_apply
  option :no => :caring_for_child?
end

## Q4
multiple_choice :caring_for_child? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :child_care_reason
  end
  option :caring_for_child => :relationship_with_child?
  option :caring_for_adult => :relationship_with_adult_group?
  option :neither => :no_right_to_apply
end

## Q5
multiple_choice :relationship_with_child? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :wrong_relationship_reason
  end
  option :yes => :responsible_for_upbringing? 
  option :no => :no_right_to_apply
end

## Q6 
multiple_choice :responsible_for_upbringing? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :upbringing_reason
  end
  option :yes => :right_to_apply
  option :no => :no_right_to_apply
end

## Q7
multiple_choice :relationship_with_adult_group? do
  calculate :no_right_to_apply_reason do
    PhraseList.new :wrong_relationship_reason
  end
  option :family_member  => :right_to_apply
  option :partner => :right_to_apply
  option :guardian => :right_to_apply
  option :other_relationship => :right_to_apply
  option :none => :no_right_to_apply
end


## A1
outcome :no_right_to_apply
## A2
outcome :right_to_apply