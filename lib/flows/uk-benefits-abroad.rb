status :draft
satisfies_need "100490"

exclude_countries = %w(holy-see british-antarctic-territory)
additional_countries = [OpenStruct.new(slug: "jersey", name: "Jersey"), OpenStruct.new(slug: "guernsey", name: "Guernsey")]

going_abroad = SmartAnswer::Predicate::VariableMatches.new(:going_or_already_abroad, 'going_abroad', nil, 'going abroad')
already_abroad = SmartAnswer::Predicate::VariableMatches.new(:going_or_already_abroad, 'already_abroad', nil, 'already abroad')
responded_with_eea_country = SmartAnswer::Predicate::RespondedWith.new(
  %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia
    finland france germany gibraltar greece hungary iceland ireland italy
    latvia liechtenstein lithuania luxembourg malta netherlands norway
    poland portugal romania slovakia slovenia spain sweden switzerland),
  "EEA country"
)
countries_of_former_yugoslavia = %w(bosnia-and-herzegovina kosovo macedonia montenegro serbia).freeze
responded_with_former_yugoslavia = SmartAnswer::Predicate::RespondedWith.new(
  countries_of_former_yugoslavia,
  "former Yugoslavia"
)
social_security_countries_jsa = responded_with_former_yugoslavia | SmartAnswer::Predicate::RespondedWith.new(%w(guernsey jersey new-zealand))
social_security_countries_iidb = responded_with_former_yugoslavia | SmartAnswer::Predicate::RespondedWith.new(%w(barbados bermuda guernsey jersey israel jamaica mauritius philippines turkey))
social_security_countries_bereavement_benefits = responded_with_former_yugoslavia | SmartAnswer::Predicate::RespondedWith.new(%w(barbados bermuda canada guernsey jersey israel jamaica mauritius new-zealand philippines turkey usa))

# Q1
multiple_choice :going_or_already_abroad? do
  option :going_abroad
  option :already_abroad
  save_input_as :going_or_already_abroad

  calculate :question_titles do
    PhraseList.new(:"#{going_or_already_abroad}_country_question_title")
  end

  calculate :how_long_question_titles do
    PhraseList.new(:"#{going_or_already_abroad}_how_long_question_title")
  end

  calculate :already_abroad_text do
    if responses.last == 'already_abroad'
      PhraseList.new(:already_abroad_text)
      end
  end

  calculate :already_abroad_text_two do
    if responses.last == 'already_abroad'
      PhraseList.new(:already_abroad_text_two)
    end
  end

  calculate :iidb_maybe do
    if responses.last == 'already_abroad'
      PhraseList.new(:iidb_maybe_text)
    end
  end

  next_node :which_benefit?
end

# Q2
multiple_choice :which_benefit? do
  option :jsa
  option :pension
  option :winter_fuel_payment => :which_country? # Q4
  option :maternity_benefits => :which_country? # Q3b
  option :child_benefit => :which_country? # Q3b
  option :iidb => :iidb_already_claiming? # Q22
  option :ssp => :which_country? # Q11
  option :esa => :esa_how_long_abroad? # Q20
  option :disability_benefits => :db_how_long_abroad? # Q24
  option :bereavement_benefits => :which_country? # Q3b
  option :tax_credits => :eligible_for_tax_credits? # Q14
  option :income_support

  save_input_as :benefit

  on_condition(going_abroad) do
    next_node_if(:jsa_how_long_abroad?, responded_with('jsa'))
    next_node_if(:pension_going_abroad_outcome, responded_with('pension'))
    next_node_if(:is_how_long_abroad?, responded_with('income_support'))
  end
  on_condition(already_abroad) do
    next_node_if(:which_country?, responded_with('jsa'))
    next_node_if(:pension_already_abroad_outcome, responded_with('pension'))
    next_node_if(:is_already_abroad_outcome, responded_with('income_support'))
  end
end

# Q3 going abroad
multiple_choice :jsa_how_long_abroad? do
  option :less_than_a_year_medical
  option :less_than_a_year_other
  option :more_than_a_year

  save_input_as :how_long_abroad_jsa

  next_node_if(:jsa_less_than_a_year_medical_outcome, responded_with("less_than_a_year_medical"))
  next_node_if(:jsa_less_than_a_year_other_outcome, responded_with("less_than_a_year_other"))
  next_node_if(:which_country?, responded_with("more_than_a_year"))
end


country_select :which_country?,additional_countries: additional_countries, exclude_countries: exclude_countries do

  save_input_as :country

  calculate :country_name do
    (WorldLocation.all + additional_countries).find { |c| c.slug == country }.name
  end

#jsa
  on_condition(variable_matches(:benefit, 'jsa')) do
    on_condition(already_abroad) do
      next_node_if(:jsa_eea_already_abroad_outcome, responded_with_eea_country) # A3 or A4
      next_node_if(:jsa_social_security_already_abroad_outcome, social_security_countries_jsa) # A5 or A6
    end

    on_condition(going_abroad) do
      next_node_if(:jsa_eea_going_abroad_outcome, responded_with_eea_country) # A3 or A4
      next_node_if(:jsa_social_security_going_abroad_outcome, social_security_countries_jsa) # A5 or A6
    end
    next_node(:jsa_not_entitled_outcome) # A7
  end
#maternity
  on_condition(variable_matches(:benefit, 'maternity_benefits')) do
    next_node_if(:working_for_a_uk_employer?, responded_with_eea_country)
    next_node(:employer_paying_ni?)
  end
#wfp
  on_condition(variable_matches(:benefit, 'winter_fuel_payment')) do
    next_node_if(:wfp_eea_eligible_outcome, responded_with_eea_country) # A10
    next_node(:wfp_not_eligible_outcome) # A11
  end
#child benefit
  on_condition(variable_matches(:benefit, 'child_benefit')) do
    next_node_if(:do_either_of_the_following_apply?, responded_with_eea_country) # Q10
    on_condition(responded_with_former_yugoslavia) do
      next_node_if(:child_benefit_fy_going_abroad_outcome, going_abroad) # A17
      next_node(:child_benefit_fy_already_abroad_outcome) # A18
    end
    next_node_if(:child_benefit_ss_outcome, responded_with(%w(barbados canada guernsey israel jersey mauritius new-zealand))) # A19
    next_node_if(:child_benefit_jtu_outcome, responded_with(%w(jamaica turkey usa))) # A20
    next_node(:child_benefit_not_entitled_outcome) # A22
  end
#iidb
  on_condition(variable_matches(:benefit, 'iidb')) do
    on_condition(going_abroad) do
      next_node_if(:iidb_going_abroad_eea_outcome, responded_with_eea_country) # A42
      next_node_if(:iidb_going_abroad_ss_outcome, social_security_countries_iidb) # A44
      next_node(:iidb_going_abroad_other_outcome) # A46
    end
    on_condition(already_abroad) do
      next_node_if(:iidb_already_abroad_eea_outcome, responded_with_eea_country) # A43
      next_node_if(:iidb_already_abroad_ss_outcome, social_security_countries_iidb) # A45
      next_node(:iidb_already_abroad_other_outcome) # A47
    end
  end
#disability benefits
  on_condition(variable_matches(:benefit, 'disability_benefits')) do
    next_node_if(:db_claiming_benefits?, responded_with_eea_country)
    next_node_if(:db_going_abroad_other_outcome, going_abroad) # A50
    next_node(:db_already_abroad_other_outcome) # A51
  end
#ssp
  on_condition(variable_matches(:benefit, 'ssp')) do
    next_node_if(:working_for_uk_employer_ssp?, responded_with_eea_country) # Q12
    next_node(:employer_paying_ni?) # Q13
  end
#tax credits
  on_condition(variable_matches(:benefit, 'tax_credits')) do
    next_node_if(:tax_credits_currently_claiming?, responded_with_eea_country) # Q18
    next_node(:tax_credits_unlikely_outcome) # A29
  end
#esa
  on_condition(variable_matches(:benefit, 'esa')) do
    on_condition(going_abroad) do
      next_node_if(:esa_going_abroad_eea_outcome, responded_with_eea_country) # A37
      next_node(:esa_going_abroad_other_outcome) # A39
    end
    on_condition(already_abroad) do
      next_node_if(:esa_already_abroad_eea_outcome, responded_with_eea_country) # A38
      next_node(:esa_already_abroad_other_outcome) # A40
    end
  end
#bereavement_benefits
  on_condition(variable_matches(:benefit, 'bereavement_benefits')) do
    on_condition(going_abroad) do
      next_node_if(:bb_going_abroad_eea_outcome, responded_with_eea_country) # A54
      next_node_if(:bb_going_abroad_ss_outcome, social_security_countries_bereavement_benefits) # A56
      next_node(:bb_going_abroad_other_outcome) # A58
    end
    on_condition(already_abroad) do
      next_node_if(:bb_already_abroad_eea_outcome, responded_with_eea_country) # A55
      next_node_if(:bb_already_abroad_ss_outcome, social_security_countries_bereavement_benefits) # A57
      next_node(:bb_already_abroad_other_outcome) # A59
    end
  end
end

# Q6
multiple_choice :working_for_a_uk_employer? do
  option yes: :eligible_for_smp?
  option no: :maternity_benefits_maternity_allowance_outcome # A12
end

# Q7
multiple_choice :eligible_for_smp? do
  option yes: :maternity_benefits_eea_entitled_outcome # A13
  option no: :maternity_benefits_maternity_allowance_outcome # A12
end

# Q8
multiple_choice :employer_paying_ni? do
  option :yes
  option :no

  #SSP
  on_condition(variable_matches(:benefit, 'ssp')) do
    on_condition(going_abroad) do
      next_node_if(:ssp_going_abroad_entitled_outcome, responded_with('yes')) # A23
      next_node(:ssp_going_abroad_not_entitled_outcome) # A25
    end
    on_condition(already_abroad) do
      next_node_if(:ssp_already_abroad_entitled_outcome, responded_with('yes')) # A24
      next_node(:ssp_already_abroad_not_entitled_outcome) # A26
    end
  end
  next_node_if(:eligible_for_smp?, responded_with('yes'))
  on_condition(variable_matches(:country, countries_of_former_yugoslavia + %w(barbados guernsey jersey israel turkey))) do
    on_condition(already_abroad) do
      next_node(:maternity_benefits_social_security_already_abroad_outcome) # A14 or A15
    end
    next_node_if(:maternity_benefits_social_security_going_abroad_outcome) # A14 or A15
  end
  next_node(:maternity_benefits_not_entitled_outcome) # A17
end

# Q10
multiple_choice :do_either_of_the_following_apply? do
  option yes: :child_benefit_entitled_outcome # A21
  option no: :child_benefit_not_entitled_outcome # A22
end

# Q12
multiple_choice :working_for_uk_employer_ssp? do
  option :yes
  option :no

  on_condition(going_abroad) do
    next_node_if(:ssp_going_abroad_entitled_outcome, responded_with('yes')) # A23
    next_node(:ssp_going_abroad_not_entitled_outcome) # A25
  end
  on_condition(already_abroad) do
    next_node_if(:ssp_already_abroad_entitled_outcome, responded_with('yes')) # A24
    next_node(:ssp_already_abroad_not_entitled_outcome) # A26
  end
end

# # Q13
# multiple_choice :employer_paying_ni_ssp? do
#   option :yes
#   option :no

#   on_condition(going_abroad) do
#     next_node_if(:ssp_going_abroad_entitled_outcome, responded_with('yes')) # A23
#     next_node(:ssp_going_abroad_not_entitled_outcome) # A25
#   end
#   on_condition(already_abroad) do
#     next_node_if(:ssp_already_abroad_entitled_outcome, responded_with('yes')) # A24
#     next_node(:ssp_already_abroad_not_entitled_outcome) # A26
#   end
# end

# Q14
multiple_choice :eligible_for_tax_credits? do
  option :crown_servant => :tax_credits_crown_servant_outcome # A27
  option :cross_border_worker => :tax_credits_cross_border_worker_outcome # A28
  option :none_of_the_above => :tax_credits_how_long_abroad?
end

# Q15
multiple_choice :tax_credits_how_long_abroad? do
  option tax_credits_up_to_a_year: :tax_credits_why_going_abroad? # Q19
  option tax_credits_more_than_a_year: :tax_credits_children? # Q16
end

# Q16
multiple_choice :tax_credits_children? do
  option yes: :which_country? # Q17
  option no: :tax_credits_unlikely_outcome # A29
end

# Q18
multiple_choice :tax_credits_currently_claiming? do
  option yes: :tax_credits_eea_entitled_outcome # A30
  option no: :tax_credits_unlikely_outcome # A29
end

# Q19
multiple_choice :tax_credits_why_going_abroad? do
  option tax_credits_holiday: :tax_credits_holiday_outcome # A31
  option tax_credits_medical_treatment: :tax_credits_medical_death_outcome #A32
  option tax_credits_death: :tax_credits_medical_death_outcome #A32
end

# Q20
multiple_choice :esa_how_long_abroad? do
  option :esa_under_a_year_medical
  option :esa_under_a_year_other
  option :esa_more_than_a_year

  on_condition(going_abroad) do
    next_node_if(:esa_going_abroad_under_a_year_medical_outcome, responded_with('esa_under_a_year_medical'))
    next_node_if(:esa_going_abroad_under_a_year_other_outcome, responded_with('esa_under_a_year_other'))
  end
  on_condition(already_abroad) do
    next_node_if(:esa_already_abroad_under_a_year_medical_outcome, responded_with('esa_under_a_year_medical'))
    next_node_if(:esa_already_abroad_under_a_year_other_outcome, responded_with('esa_under_a_year_other'))
  end
  next_node(:which_country?)
end

# Q22
multiple_choice :iidb_already_claiming? do
  option yes: :which_country? # Q3b
  option no: :iidb_maybe_outcome # A41
end

# Q24
multiple_choice :db_how_long_abroad? do
  option :temporary
  option :permanent => :which_country? # Q25

  next_node_if(:db_going_abroad_temporary_outcome, going_abroad) # A48
  next_node(:db_already_abroad_temporary_outcome) # A49
end

# Q26
multiple_choice :db_claiming_benefits? do
  option :yes
  option :no

  on_condition(going_abroad) do
    next_node_if(:db_going_abroad_eea_outcome, responded_with('yes')) # A52
    next_node(:db_going_abroad_other_outcome) # A50
  end
  on_condition(already_abroad) do
    next_node_if(:db_already_abroad_eea_outcome, responded_with('yes')) # A53
    next_node(:db_already_abroad_other_outcome) # A51
  end
end

# Q28
multiple_choice :is_how_long_abroad? do
  option is_under_a_year_medical: :is_under_a_year_medical_outcome # A60
  option is_under_a_year_other: :is_claiming_benefits? # Q29
  option is_more_than_a_year: :is_more_than_a_year_outcome # A61
end

# Q29
multiple_choice :is_claiming_benefits? do
  option yes: :is_claiming_benefits_outcome # A62
  option no: :is_either_of_the_following? # Q30
end

# Q30
multiple_choice :is_either_of_the_following? do
  option yes: :is_abroad_for_treatment? # Q31
  option no: :is_any_of_the_following_apply? # Q33
end

# Q31
multiple_choice :is_abroad_for_treatment? do
  option yes: :is_abroad_for_treatment_outcome # A63
  option no: :is_work_or_sick_pay? # Q32
end

# Q32
multiple_choice :is_work_or_sick_pay? do
  option yes: :is_abroad_for_treatment_outcome # A63
  option no: :is_not_eligible_outcome # A64
end

# Q33
multiple_choice :is_any_of_the_following_apply? do
  option yes: :is_not_eligible_outcome # A64
  option no: :is_abroad_for_treatment_outcome # A63
end

outcome :jsa_less_than_a_year_medical_outcome # A1
outcome :jsa_less_than_a_year_other_outcome # A2
outcome :jsa_eea_going_abroad_outcome # A3
outcome :jsa_eea_already_abroad_outcome # A4
outcome :jsa_social_security_going_abroad_outcome # A5
outcome :jsa_social_security_already_abroad_outcome # A6
outcome :jsa_not_entitled_outcome # A7
outcome :pension_going_abroad_outcome # A8
outcome :pension_already_abroad_outcome # A9
outcome :wfp_eea_eligible_outcome # A10
outcome :wfp_not_eligible_outcome # A11
outcome :maternity_benefits_maternity_allowance_outcome # A12
outcome :maternity_benefits_eea_entitled_outcome # A13
outcome :maternity_benefits_social_security_going_abroad_outcome # A14
outcome :maternity_benefits_social_security_already_abroad_outcome # A15
outcome :maternity_benefits_not_entitled_outcome # A16
outcome :child_benefit_fy_going_abroad_outcome # A17
outcome :child_benefit_fy_already_abroad_outcome # A18
outcome :child_benefit_ss_outcome # A19
outcome :child_benefit_jtu_outcome # A20
outcome :child_benefit_entitled_outcome # A21
outcome :child_benefit_not_entitled_outcome # A22
outcome :ssp_going_abroad_entitled_outcome # A23
outcome :ssp_already_abroad_entitled_outcome # A24
outcome :ssp_going_abroad_not_entitled_outcome # A25
outcome :ssp_already_abroad_not_entitled_outcome # A26
outcome :tax_credits_crown_servant_outcome do # A27
  precalculate :tax_credits_crown_servant do
    PhraseList.new(:"tax_credits_#{going_or_already_abroad}_helpline")
  end
end
outcome :tax_credits_cross_border_worker_outcome do # A28
  precalculate :tax_credits_cross_border_worker do
    PhraseList.new(:"tax_credits_cross_border_#{going_or_already_abroad}", :tax_credits_cross_border, :"tax_credits_#{going_or_already_abroad}_helpline")
  end
end
outcome :tax_credits_unlikely_outcome #A29
outcome :tax_credits_eea_entitled_outcome # A30
outcome :tax_credits_holiday_outcome do # A31
  precalculate :tax_credits_holiday do
    PhraseList.new(:"tax_credits_holiday_#{going_or_already_abroad}", :tax_credits_holiday, :"tax_credits_#{going_or_already_abroad}_helpline")
  end
end
outcome :tax_credits_medical_death_outcome do # A32
  precalculate :tax_credits_medical_death do
    PhraseList.new(:"tax_credits_medical_death_#{going_or_already_abroad}", :tax_credits_medical_death, :"tax_credits_#{going_or_already_abroad}_helpline")
  end
end
outcome :esa_going_abroad_under_a_year_medical_outcome # A33
outcome :esa_already_abroad_under_a_year_medical_outcome # A34
outcome :esa_going_abroad_under_a_year_other_outcome # A35
outcome :esa_already_abroad_under_a_year_other_outcome # A36
outcome :esa_going_abroad_eea_outcome # A37
outcome :esa_already_abroad_eea_outcome # A38
outcome :esa_going_abroad_other_outcome # A39
outcome :esa_already_abroad_other_outcome # A40
outcome :iidb_maybe_outcome # A41
outcome :iidb_going_abroad_eea_outcome # A42
outcome :iidb_already_abroad_eea_outcome # A43
outcome :iidb_going_abroad_ss_outcome # A44
outcome :iidb_already_abroad_ss_outcome # A45
outcome :iidb_going_abroad_other_outcome # A46
outcome :iidb_already_abroad_other_outcome # A47
outcome :db_going_abroad_temporary_outcome # A48
outcome :db_already_abroad_temporary_outcome # A49
outcome :db_going_abroad_other_outcome # A50
outcome :db_already_abroad_other_outcome # A51
outcome :db_going_abroad_eea_outcome # A52
outcome :db_already_abroad_eea_outcome # A53
outcome :bb_going_abroad_eea_outcome # A54
outcome :bb_already_abroad_eea_outcome # A55
outcome :bb_going_abroad_ss_outcome # A56
outcome :bb_already_abroad_ss_outcome # A57
outcome :bb_going_abroad_other_outcome # A58
outcome :bb_already_abroad_other_outcome # A59
outcome :is_under_a_year_medical_outcome # A60
outcome :is_more_than_a_year_outcome # A61
outcome :is_claiming_benefits_outcome # A62
outcome :is_abroad_for_treatment_outcome # A63
outcome :is_not_eligible_outcome # A64
outcome :is_already_abroad_outcome # A65
