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
    elsif describes_you == ["care_for_adult"]
      :do_any_of_these_describe_the_adult_youre_caring_for?
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

## Q4
multiple_choice :do_any_of_these_describe_the_adult_youre_caring_for? do
  option :yes => :right_to_apply
  option :no => :no_right_to_apply
end

## A1
outcome :no_right_to_apply
## A2
outcome :right_to_apply
