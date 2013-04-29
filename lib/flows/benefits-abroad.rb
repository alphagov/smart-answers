satisfies_need "392"
status :draft

eea_countries = %w(austria belgium bulgaria cyprus czech-republic denmark estonia finland france germany gibraltar greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

social_security_countries = %w(croatia bosnia-and-herzegovina croatia guernsey jersey kosovo macedonia montenegro new-zealand serbia)

maternity_ss_countries = social_security_countries + %w(barbados israel jersey turkey)

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
  #option :child_benefits => # Q10
  #option :iidb => # Q24
  #option :ssp => # Q12
  #option :esa => # Q22
  #option :disability_benefits => # Q26
  #option :bereavement_benefits => # Q32
  #option :tax_credits => # Q15
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
# Q9
multiple_choice :employer_paying_ni? do
  option :yes
  option :no
  next_node do |response|
    if response == 'yes'
      :eligible_for_maternity_pay?
    elsif maternity_ss_countries.include?(maternity_country)
      :maternity_allowance # A10
    else
      :maternity_not_entitled # A11
    end
  end
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
# A 11
outcome :maternity_not_entitled
