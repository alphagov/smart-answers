satisfies_need "B188"
status :draft

multiple_choice :have_you_had_licence_for_4_of_6_years? do
  option :yes => :have_you_been_disqualified_in_last_4_years?
  option :no => :havent_had_licence_for_long_enough

  calculate :content_sections do
    if responses.last == 'no'
      PhraseList.new :ADI_required_legal_warning, :acronym_definitions
    end
  end
end

multiple_choice :have_you_been_disqualified_in_last_4_years? do
  option :yes => :cant_because_disqualified
  option :no => :do_you_have_a_criminal_record?

  calculate :content_sections do
    if responses.last == 'yes'
      PhraseList.new :unlikely_apply_anyway, :apply_steps, :criminal_record_check, :apply_to_dsa, :ADI_required_legal_warning, :acronym_definitions
    end
  end
end

multiple_choice :do_you_have_a_criminal_record? do
  option :yes => :was_offence_violent_or_sex_related?
  option :no => :do_you_have_a_disability?

  calculate :have_criminal_record do
    responses.last == 'yes'
  end
end

multiple_choice :was_offence_violent_or_sex_related? do
  option :yes => :very_unlikely_because_of_criminal_record
  option :no => :do_you_have_a_disability?

  calculate :content_sections do
    if responses.last == 'yes'
      PhraseList.new :unlikely_apply_anyway, :apply_steps, :criminal_record_check, :apply_to_dsa, :ADI_required_legal_warning, :acronym_definitions
    end
  end
end

multiple_choice :do_you_have_a_disability? do
  option :yes
  option :no

  calculate :have_disability do
    responses.last == 'yes'
  end

  next_node :are_you_driving_instructor_in_ec_country?
end

multiple_choice :are_you_driving_instructor_in_ec_country? do
  option :yes => :can_apply_to_transfer_registration
  option :no => :can_start_process_of_applying

  calculate :content_sections do
    sections = PhraseList.new
    if responses.last == 'no'
      if have_disability
        sections << :apply_steps_with_emergency_control << :emergency_control
      else
        sections << :apply_steps
      end
      sections << :criminal_record_check
      sections << :criminal_record_warning if have_criminal_record
      sections << :apply_to_dsa
    else
      sections << (have_disability ? :transfer_steps_with_emergency_control : :transfer_steps)
      sections << :gb_counterpart_licence
      sections << :emergency_control if have_disability
      sections << :transfer_registration
      sections << :criminal_record_warning if have_criminal_record
    end
    sections << :acronym_definitions
  end
end

outcome :can_start_process_of_applying
outcome :can_apply_to_transfer_registration

outcome :havent_had_licence_for_long_enough
outcome :cant_because_disqualified
outcome :very_unlikely_because_of_criminal_record
