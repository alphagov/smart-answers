# -*- coding: utf-8 -*-
status :draft
satisfies_need "357"

## Q1
multiple_choice :are_you_an_employee_or_employer? do
  option :employee => :which_one_of_these_describes_you?
  option :employer => :which_one_of_these_describes_you?
end

## Q2
checkbox_question :which_one_of_these_describes_you? do
  option :under_17
  option :care_for_adult
  option :less_than_26_weeks
  option :agency_worker
  option :member_of_armed_forces
  option :request_in_last_12_months
  option :none_of_these

  next_node do |response|
    describes_you = response.split(",")

    if describes_you == ["none_of_these"] || describes_you.include?("none_of_these")
      :no_right_to_apply
    elsif describes_you == ["under_17"]
      :responsible_for_childs_upbringing?
    elsif describes_you.to_set.superset?(["under_17", "care_for_adult"].to_set)
      :no_right_to_apply
    elsif describes_you.to_set.superset?(["less_than_26_weeks","agency_worker","member_of_armed_forces","request_in_last_12_months"].to_set) ||
        !(describes_you & ["less_than_26_weeks","agency_worker","member_of_armed_forces","request_in_last_12_months"]).empty?
      :no_right_to_apply
    end
  end
end

## Q3
multiple_choice :responsible_for_childs_upbringing? do
  option :yes => :right_to_apply
  option :no => :no_right_to_apply
end

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
