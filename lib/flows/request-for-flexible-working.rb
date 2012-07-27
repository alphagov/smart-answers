status :draft
section_slug "work"
satisfies_need "9999"

checkbox_question :tick_boxes_that_apply? do
  option :employee
  option :continuous_employment
  option :not_applied_for_flexible_working
  option :agency_worker
  option :armed_forces

  next_node do |response|
    options = response.split(',')
    if options.sort == %w(continuous_employment employee not_applied_for_flexible_working)
      :caring_for_child?
    else
      :no_right_to_apply
    end
  end
end

multiple_choice :caring_for_child? do
  option :caring_for_child => :relationship_with_child?
  option :caring_for_adult => :relationship_with_adult?
  option :neither => :no_right_to_apply
end

checkbox_question :relationship_with_child? do
  option :relationship
  option :responsible_for_upbringing

  next_node do |response|
    options = response.split(',')
    if options.sort == %w(relationship responsible_for_upbringing)
      :right_to_apply
    else
      :no_right_to_apply
    end
  end
end

multiple_choice :relationship_with_adult? do
  option :one_of_these => :right_to_apply
  option :not_one_of_these => :no_right_to_apply
end

outcome :no_right_to_apply
outcome :right_to_apply