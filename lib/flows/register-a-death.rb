satisfies_need "2189"
status :draft


multiple_choice :where_did_the_death_happen? do
  option :england_wales
  option :scotland_northern_ireland_abroad

  save_input_as :where_death_happened

  next_node :did_the_person_die_at_home_hospital?
end

multiple_choice :did_the_person_die_at_home_hospital? do
  option :at_home_hospital
  option :elsewhere

  calculate :died_at_home_hospital do
    responses.last == 'at_home_hospital'
  end

  next_node :was_death_expected?
end

multiple_choice :was_death_expected? do
  option :yes
  option :no

  calculate :death_expected do
    responses.last == 'yes'
  end
  calculate :content_sections do
    sections = PhraseList.new
    if where_death_happened == 'england_wales'
      sections << :intro_ew << :who_can_register
      sections << (died_at_home_hospital ? :who_can_register_home_hospital : :who_can_register_elsewhere)
      sections << :"what_you_need_to_do_#{death_expected ? :expected : :unexpected}"
      sections << :need_to_tell_registrar
      sections << :"documents_youll_get_ew_#{death_expected ? :expected : :unexpected}"
    else
      sections << :intro_other
      sections << :intro_other_unexpected unless death_expected
      sections << :who_can_register
      sections << :"who_can_register_#{died_at_home_hospital ? :home_hospital : :elsewhere}"
      sections << :documents_youll_need
      sections << :"documents_youll_get_other_#{death_expected ? :expected : :unexpected}"
    end
    sections
  end

  next_node :done
end

outcome :done
