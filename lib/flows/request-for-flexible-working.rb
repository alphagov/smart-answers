status :draft
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
end

outcome :no_right_to_apply