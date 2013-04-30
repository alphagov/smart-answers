satisfies_need "392"
status :draft

eea_countries = %w(austria belgium bulgaria cyprus czech-republic denmark estonia finland france germany gibraltar greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

social_security_countries = %w(croatia bosnia-and-herzegovina croatia guernsey jersey kosovo macedonia montenegro new-zealand serbia)



# Q1
multiple_choice :going_or_already_abroad? do
  option :going_abroad
  option :already_abroad
  save_input_as :going_or_already_abroad
  next_node :which_benefit?
end
# Q2
multiple_choice :which_benefit? do
  option :jsa => :which_country_are_you_moving_to_jsa? # Q3
  option :pension => :pension_outcome # A2
  option :wfp => :which_country_are_you_moving_to_wfp? # Q4
  option :maternity_benefits => :which_country_are_you_moving_to_maternity? # Q6
  option :child_benefits => :which_country_are_you_moving_to_cb? # Q10
  #option :iidb => # Q24
  option :ssp => :which_country_are_you_moving_to_ssp? # Q31
  #option :esa => # Q22
  #option :disability_benefits => # Q26 # Leave for now.
  #option :bereavement_benefits => # Q32
  option :tax_credits => :eligible_for_tax_credits? # Q16
  save_input_as :which_benefit
end
# Q3
country_select :which_country_are_you_moving_to_jsa?, :use_legacy_data => true do
  next_node do |response|
    if eea_countries.include?(response)
      :jsa_eea
    elsif social_security_countries.include?(response)
      :jsa_social_security
    else
      :jsa_not_entitled
    end
  end
end
# Q4
country_select :which_country_are_you_moving_to_wfp?, :use_legacy_data => true do
  next_node do |response|
    if eea_countries.include?(response)
      :qualify_for_wfp?
    else
      :wfp_not_entitled
    end
  end
end
# Q5
multiple_choice :qualify_for_wfp? do
  option :yes => :wfp_outcome # A7
  option :no => :wfp_not_entitled # A6
end
# Q6
country_select :which_country_are_you_moving_to_maternity?, :use_legacy_data => true do
  save_input_as :maternity_country
  next_node do |response|
    if eea_countries.include?(response)
      :working_for_a_uk_employer?  
    else
      :employer_paying_ni?
    end
  end
end
# Q7
multiple_choice :working_for_a_uk_employer? do
  option :yes => :eligible_for_maternity_pay? # Q8
  option :no => :smp_not_entitled # A8
end
# Q8
multiple_choice :eligible_for_maternity_pay? do
  option :yes => :smp_outcome # A9
  option :no => :smp_not_entitled #A8
end
# Q9, Q10
multiple_choice :employer_paying_ni? do
  option :yes
  option :no
  next_node do |response|
    maternity_ss_countries = social_security_countries + %w(barbados israel jersey turkey)
    if response == 'yes'
      :eligible_for_maternity_pay? # Q8
    elsif maternity_ss_countries.include?(maternity_country)
      :maternity_allowance # A10
    else
      :maternity_not_entitled # A11
    end
  end
end
# Q11
country_select :which_country_are_you_moving_to_cb?, :use_legacy_data => true do
  next_node do |response|
    if eea_countries.include?(response)
      :do_either_of_the_following_apply? # Q12
    elsif %w(bosnia-and-herzegovina croatia kosovo macedonia montenegro serbia).include?(response)
      :cb_fy_social_security_outcome # A12
    elsif %w(barbados canada guernsey israel jersey mauritius new-zealand).include?(response)
      :cb_social_security_outcome # A13
    elsif %w(jamaica turkey united-states).include?(response)
      :cb_jtu_not_entitled # A14
    else
      :cb_not_entitled # A16
    end
  end
end
# Q12
multiple_choice :do_either_of_the_following_apply? do
  option :yes => :cb_outcome # A15
  option :no => :cb_not_entitled # A16
end
# Q13
country_select :which_country_are_you_moving_to_ssp?, :use_legacy_data => true do
  next_node do |response|
    if eea_countries.include?(response)
      :working_for_a_uk_employer_ssp? # Q14
    else
      :employer_paying_ni_ssp? # Q15
    end
  end
end
# Q14
multiple_choice :working_for_a_uk_employer_ssp? do
  option :yes => :ssp_outcome # A17
  option :no => :ssp_not_entitled # A18
end
# Q15
multiple_choice :employer_paying_ni_ssp? do
  option :yes => :ssp_outcome # A17
  option :no => :ssp_not_entitled # A18
end
# Q16
multiple_choice :eligible_for_tax_credits? do
  option :yes => :are_you_one_of_the_following? # Q17
  option :no => :tax_credits_unlikely # A19
end
# Q17
multiple_choice :are_you_one_of_the_following? do
  option :crown_servant => :tax_credits_outcome # A20
  option :cross_border_worker => :tax_credits_exceptions # A21
  option :none_of_the_above => :how_long_are_you_abroad_for? # Q21
end
# Q18
multiple_choice :do_you_have_children? do
  option :yes => :where_are_you_moving_to_tax_credits? # Q19
  option :no => :tax_credits_outcome # A20
end
# Q19
country_select :where_are_you_moving_to_tax_credits?, :use_legacy_data => true do
  next_node do |response|
    if eea_countries.include?(response)
      :currently_claiming? # Q20
    else
      :tax_credits_unlikely # A19
    end
  end
end
# Q20
multiple_choice :currently_claiming? do
  option :yes => :tax_credits_possible # A22
  option :no => :tax_credits_unlikely # A19
end
# Q21
multiple_choice :how_long_are_you_abroad_for? do
  option :up_to_a_year => :why_are_you_going_abroad? # Q22
  option :more_than_a_year => :do_you_have_children? # Q18
end
# Q22
multiple_choice :why_are_you_going_abroad? do
  option :holiday_or_business_trip => :tax_credits_continue_8_weeks # A23
  option :medical_treatment => :tax_credits_continue_12_weeks # A24
  option :death => :tax_credits_continue_12_weeks # A24
end
# A1
outcome :not_paid_ni
# A2
outcome :pension_outcome
# A3
outcome :jsa_eea
# A4
outcome :jsa_social_security
# A5
outcome :jsa_not_entitled
# A6
outcome :wfp_not_entitled
# A7
outcome :wfp_outcome
# A8
outcome :smp_not_entitled
# A9
outcome :smp_outcome
# A10
outcome :maternity_allowance
# A11
outcome :maternity_not_entitled
# A12
outcome :cb_fy_social_security_outcome
# A13
outcome :cb_social_security_outcome
# A14
outcome :cb_jtu_not_entitled
# A15
outcome :cb_outcome
# A16
outcome :cb_not_entitled
# A17
outcome :ssp_outcome
# A18
outcome :ssp_not_entitled
# A19
outcome :tax_credits_unlikely
# A20
outcome :tax_credits_outcome
# A21
outcome :tax_credits_exceptions
# A22
outcome :tax_credits_possible
# A23
outcome :tax_credits_continue_8_weeks
# A24
outcome :tax_credits_continue_12_weeks
