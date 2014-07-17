status :draft
satisfies_need "101059"

# Q1
multiple_choice :extending_or_switching? do
  option :extend_general
  option :switch_general
  option :extend_child
  option :switch_child

  save_input_as :type_of_visa

  next_node(:sponsor_id?)
end

#Q2
value_question :sponsor_id? do

  save_input_as :sponsor_id

  calculate :data do
    Calculators::StaticDataQuery.new("tier_4_triage_data").data
  end

  calculate :sponsor_name do
    name = data["post"].merge(data["online"])[responses.last]
    raise InvalidResponse, :error unless name
    name
  end

  calculate :application_link do
    phrases = PhraseList.new
    phrases << :post_link if data["post"].keys.include?(responses.last)
    phrases << :online_link if data["online"].keys.include?(responses.last)
    phrases
  end

  calculate :extend_or_switch_visa do
    phrases = PhraseList.new
    phrases << :you_must_be_in_uk if %w(switch_general switch_child).include?(type_of_visa)
    phrases << :general_extend if %w(extend_general).include?(type_of_visa)
    phrases << :general_switch if %w(switch_general).include?(type_of_visa)
    phrases << :child_extend if %w(extend_child).include?(type_of_visa)
    phrases << :child_switch if %w(switch_child).include?(type_of_visa)
    phrases
  end
  next_node(:outcome)
end

outcome :outcome
