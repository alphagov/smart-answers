satisfies_need "B188"
status :draft

multiple_choice :have_you_had_licence_for_4_of_6_years? do
  option :yes => :have_you_been_disqualified_in_last_4_years?
  option :no => :havent_had_licence_for_long_enough
end

multiple_choice :have_you_been_disqualified_in_last_4_years? do
  option :yes => :cant_because_disqualified
  option :no => :do_you_have_a_criminal_record?
end

multiple_choice :do_you_have_a_criminal_record? do
  save_input_as :have_criminal_record

  option :yes => :was_offence_violent_or_sex_related?
  option :no => :do_you_have_a_disability?
end

multiple_choice :was_offence_violent_or_sex_related? do
  option :yes => :very_unlikely_because_of_criminal_record
  option :no => :do_you_have_a_disability?
end

multiple_choice :do_you_have_a_disability? do
  save_input_as :have_disability

  option :yes
  option :no
  next_node :are_you_driving_instructor_in_ec_country?
end

multiple_choice :are_you_driving_instructor_in_ec_country? do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      outcome_name = 'can_apply_to_transfer_registration'
    else
      outcome_name = 'can_start_process_of_applying'
    end
    outcome_name << '_with_emergency_control' if have_disability == 'yes'
    outcome_name << '_with_criminal_record' if have_criminal_record == 'yes'
    outcome_name.to_sym
  end
end

multiple_choice :foo do
  option :yes => :foo
  option :no => :foo
end

outcome :can_start_process_of_applying
outcome :can_start_process_of_applying_with_criminal_record
outcome :can_start_process_of_applying_with_emergency_control
outcome :can_start_process_of_applying_with_emergency_control_with_criminal_record

outcome :can_apply_to_transfer_registration
outcome :can_apply_to_transfer_registration_with_criminal_record
outcome :can_apply_to_transfer_registration_with_emergency_control
outcome :can_apply_to_transfer_registration_with_emergency_control_with_criminal_record

outcome :havent_had_licence_for_long_enough
outcome :cant_because_disqualified
outcome :very_unlikely_because_of_criminal_record
