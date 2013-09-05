satisfies_need "392"
status :draft

exclude_countries = %w(holy-see british-antarctic-territory)
situations = ['going_abroad','already_abroad']
eea_countries = %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia finland france germany gibraltar greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)
former_yugoslavia = %w(bosnia-and-herzegovina kosovo macedonia montenegro serbia)
social_security_countries_jsa = former_yugoslavia + %w(guernsey_jersey new-zealand)
social_security_countries_mat = former_yugoslavia + %w(barbados guernsey_jersey israel turkey)
social_security_countries_iidb = former_yugoslavia + %w(barbados bermuda guernsey_jersey israel jamaica mauritius philippines turkey)
social_security_countries_bereavement_benefits = former_yugoslavia + %w(barbados bermuda canada guernsey_jersey israel jamaica mauritius new-zealand philippines turkey usa)

# Q1
multiple_choice :going_or_already_abroad? do
  option :going_abroad
  option :already_abroad
  save_input_as :going_or_already_abroad

  calculate :question_titles do
    if responses.last == 'going_abroad'
      PhraseList.new(:going_abroad_country_question_title)
    else
      PhraseList.new(:already_abroad_country_question_title)
    end
  end

  calculate :channel_islands_question_titles do
    if responses.last == 'going_abroad'
      PhraseList.new(:ci_going_abroad_question_title)
    else
      PhraseList.new(:ci_already_abroad_question_title)
    end
  end

  calculate :channel_islands_prefix do
    if responses.last == 'going_abroad'
      PhraseList.new(:ci_going_abroad_prefix)
    else
      PhraseList.new(:ci_already_abroad_prefix)
    end
  end

  calculate :already_abroad_text do
    if responses.last == 'already_abroad'
      PhraseList.new(:already_abroad_text)
    end
  end

  next_node :which_benefit?
end

# Q2
multiple_choice :which_benefit? do
  option :jsa
  option :pension
  option :winter_fuel_payment
  option :maternity_benefits
  option :child_benefits
  option :iidb
  option :ssp
  option :esa
  option :disability_benefits
  option :bereavement_benefits
  option :tax_credits
  option :income_support

  save_input_as :benefit

  next_node do |response|
    case response
    when 'jsa'
      if going_or_already_abroad == 'going_abroad'
        :jsa_how_long_abroad?
      else
        :channel_islands?
      end
    when 'pension'
      if going_or_already_abroad == 'going_abroad'
        :pension_going_abroad_outcome # A8
      else
        :pension_already_abroad_outcome # A9
      end
    when 'winter_fuel_payment'
      :which_country_wfp?
    when 'maternity_benefits'
      :channel_islands?
    when 'child_benefits'
      :channel_islands?
    when 'iidb'
      :channel_islands?
    when 'ssp'
      :which_country_ssp?
    when 'esa'
      if going_or_already_abroad == 'already_abroad'
        :esa_how_long_abroad?
      else
        :which_country_esa?
      end
    when 'disability_benefits'
      :db_how_long_abroad?
    when 'bereavement_benefits'
      :channel_islands?
    when 'tax_credits'
      :eligible_for_tax_credits?
    when 'income_support'
      if going_or_already_abroad == 'going_abroad'
        :is_how_long_abroad?
      else
        :income_support_already_abroad_outcome
      end
    end
  end
end

# Q3a going abroad
multiple_choice :jsa_how_long_abroad? do
  option :less_than_a_year_medical => :jsa_less_than_a_year_medical_outcome # A1
  option :less_than_a_year_other => :jsa_less_than_a_year_other_outcome # A2
  option :more_than_a_year => :channel_islands? # Q3b
end

# Q3b
multiple_choice :channel_islands? do
  option :guernsey_jersey
  option :abroad

  save_input_as :country

  calculate :country_name do
    if responses.last == 'guernsey_jersey'
      PhraseList.new(:ci_country_name)
    end
  end

  next_node do |response|
    if response == 'abroad'
      :"which_country_#{benefit}?"
    else
      if benefit == 'jsa'
        :"#{benefit}_social_security_#{going_or_already_abroad}_outcome"
      elsif benefit == 'maternity_benefits'
        :employer_paying_ni?
      elsif benefit == 'child_benefits'
        :child_benefits_ss_outcome
      else
        ''
      end
    end
  end
end

# Q3c
country_select :which_country_jsa?, :exclude_countries => exclude_countries do
  situations.each do |situation|
    key = :"which_country_#{situation}_jsa"
    precalculate key do
      PhraseList.new key
    end
  end

  save_input_as :country

  calculate :country_name do
    WorldLocation.all.find { |c| c.slug == country }.name
  end

  next_node do |response|
    if eea_countries.include?(response)
      :"jsa_eea_#{going_or_already_abroad}_outcome" # A3 or A4
    elsif social_security_countries_jsa.include?(response)
      :"jsa_social_security_#{going_or_already_abroad}_outcome" # A5 or A6
    else
      :jsa_not_entitled_outcome # A7
    end
  end
end

# Q4
country_select :which_country_wfp?, :exclude_countries => exclude_countries do
  situations.each do |situation|
    key = :"which_country_#{situation}_wfp"
    precalculate key do
      PhraseList.new key
    end
  end

  next_node do |response|
    if eea_countries.include?(response)
      :wfp_eea_eligible_outcome # A10
    else
      :wfp_not_eligible_outcome # A11
    end
  end
end

# Q5
country_select :which_country_maternity_benefits?, :exclude_countries => exclude_countries do
  save_input_as :country
  situations.each do |situation|
    key = :"which_country_#{situation}_maternity"
    precalculate key do
      PhraseList.new key
    end
  end

  next_node do |response|
    if eea_countries.include?(response)
      :working_for_a_uk_employer? 
    else
      :employer_paying_ni? 
    end
  end
end

# Q6
multiple_choice :working_for_a_uk_employer? do
  option :yes => :eligible_for_smp?
  option :no => :maternity_benefits_maternity_allowance_outcome # A12
end

# Q7
multiple_choice :eligible_for_smp? do
  option :yes => :maternity_benefits_eea_entitled_outcome # A13
  option :no => :maternity_benefits_maternity_allowance_outcome # A12
end

# Q8
multiple_choice :employer_paying_ni? do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      :eligible_for_smp?
    else
      if social_security_countries_mat.include?(country)
        :"maternity_benefits_social_security_#{going_or_already_abroad}_outcome" # A14 or A15
      else
        :maternity_benefits_not_entitled_outcome # A17
      end
    end
  end
end

# Q9
country_select :which_country_child_benefits?, :exclude_countries => exclude_countries do
  save_input_as :country
  situations.each do |situation|
    key = :"which_country_#{situation}_child"
    precalculate key do
      PhraseList.new key
    end
  end

  save_input_as :country

  calculate :country_name do
    WorldLocation.all.find { |c| c.slug == country }.name
  end

  next_node do |response|
    if eea_countries.include?(response)
      :do_either_of_the_following_apply? # Q10
    elsif former_yugoslavia.include?(response)
      :"child_benefits_fy_#{going_or_already_abroad}_outcome" # A17 or A18
    elsif %w(barbados canada israel mauritius new-zealand).include?(response)
      :child_benefits_ss_outcome # A19
    elsif %w(jamaica turkey usa).include?(response)
      :child_benefits_jtu_outcome # A20
    else
      :child_benefits_not_entitled_outcome # A22
    end
  end
end

# Q10
multiple_choice :do_either_of_the_following_apply? do
  option :yes => :child_benefits_entitled_outcome # A21
  option :no => :child_benefits_not_entitled_outcome # A22
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
outcome :child_benefits_fy_going_abroad_outcome # A17
outcome :child_benefits_fy_already_abroad_outcome # A18
outcome :child_benefits_ss_outcome # A19
outcome :child_benefits_jtu_outcome # A20
outcome :child_benefits_entitled_outcome # A21
outcome :child_benefits_not_entitled_outcome # A22