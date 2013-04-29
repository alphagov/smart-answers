
# Q1
multiple_choice :going_or_already_abroad? do
  option :going_abroad
  option :already_abroad
  next_node :have_you_paid_ni_in_the_uk?
end

multiple_choice :have_you_paid_ni_in_the_uk? do
  option :yes => :which_benefit? # Q2
  option :no => :not_paid_ni # A1
end
# Q2
multiple_choice :which_benefit? do
  option :jsa => :which_country_jsa? # Q3
  option :pension => :pension_outcome # A2
  option :wfp => :which_country_wfp? # Q4
  option :maternity_benefits => :which_country_maternity? # Q6
  #option :child_benefits => # Q10
  #option :iidb => # Q24
  #option :ssp => # Q12
  #option :esa => # Q22
  #option :disability_benefits => # Q26
  #option :bereavement_benefits => # Q32
  #option :tax_credits => # Q15
end
# Q3
multiple_choice :which_country_jsa? do
  option :eea_country => :jsa_eea # A3
  option :outside_eea => :not_entitled_jsa_with_exceptions # A4
  option :none_of_the_above => :not_entitled_jsa # A5
end
# Q4
multiple_choice :which_country_wfp? do
  option :eea_country => :qualify_for_wfp? # Q5
#  option :none_of_the_above # A6
end
# Q5
multiple_choice :qualify_for_wfp? do
#  option :yes # A7
#  option :no # A6
end
# Q6
multiple_choice :which_country_maternity? do
  option :eea_country => :working_for_employer_abroad? # Q7
  option :outside_eea => :employer_paying_ni? # Q9
end
# Q7
multiple_choice :working_for_employer_abroad? do
  option :yes => :eligible_for_smp? # Q8
#  option :no => # A8
end
# A1
outcome :not_paid_ni
# A2
outcome :pension_outcome
# A3
outcome :jsa_eea
# A4
outcome :not_entitled_jsa_with_exceptions
# A5
outcome :not_entitled_jsa
