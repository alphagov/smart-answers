satisfies_need "B188"
status :published

multiple_choice :are_you_21_or_over? do
  option :yes => :have_you_had_licence_for_3_years?
  option :no => :not_old_enough

  calculate :content_sections do
    if responses.last == 'no'
      PhraseList.new :ADI_required_legal_warning, :acronym_definitions
    end
  end
end

multiple_choice :have_you_had_licence_for_3_years? do
  option :yes => :are_you_driving_instructor_in_ec_country?
  option :no => :havent_had_licence_for_long_enough

  calculate :content_sections do
    if responses.last == 'no'
      PhraseList.new :ADI_required_legal_warning, :acronym_definitions
    end
  end
end

multiple_choice :are_you_driving_instructor_in_ec_country? do
  option :yes => :can_apply_to_transfer_registration
  option :no => :have_you_been_disqualified_or_6_points?

  calculate :content_sections do
    if responses.last == 'yes'
      PhraseList.new :DSA_guide_to_ADI_register, :acronym_definitions
    end
  end
end

multiple_choice :have_you_been_disqualified_or_6_points? do
  option :yes => :can_start_process_of_applying
  option :no => :what_licence_type?

  calculate :content_sections do
    if responses.last == 'yes'
      PhraseList.new :apply_to_dsa_with_endorsments, :apply_with_caveats_what_next, :DSA_guide_to_ADI_register, :acronym_definitions
    end
  end
end

multiple_choice :what_licence_type? do
  option :manual => :non_motoring_offences?
  option :automatic => :because_of_disability?
end

multiple_choice :because_of_disability? do
  option :yes => :non_motoring_offences?
  option :no => :cant_because_limited_licence

  calculate :disabled_driver do
    responses.last == 'yes'
  end
  calculate :content_sections do
    if ! disabled_driver
      PhraseList.new :ADI_required_legal_warning, :acronym_definitions
    end
  end
end

multiple_choice :non_motoring_offences? do
  option :yes
  option :no

  calculate :content_sections do
    sections = PhraseList.new
    if responses.last == 'yes'
      sections << :apply_to_dsa_with_criminal_record
      sections << (disabled_driver ? :apply_with_caveats_and_emergency_control_what_next : :apply_with_caveats_what_next)
    else
      if disabled_driver
        sections << :apply_steps_with_emergency_control
        sections << :emergency_control
      else
        sections << :apply_steps
      end
      sections << :criminal_record_check
      sections << :apply_to_dsa
    end
    sections << :DSA_guide_to_ADI_register
    sections << :acronym_definitions
  end

  next_node :can_start_process_of_applying
end

outcome :can_start_process_of_applying
outcome :can_apply_to_transfer_registration

outcome :not_old_enough
outcome :havent_had_licence_for_long_enough
outcome :cant_because_limited_licence
