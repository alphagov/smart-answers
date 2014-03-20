status :published
satisfies_need "2969"

additional_countries = UkbaCountry.all

exclude_countries = %w(american-samoa british-antarctic-territory british-indian-ocean-territory french-guiana french-polynesia gibraltar guadeloupe holy-see martinique mayotte new-caledonia reunion st-pierre-and-miquelon wallis-and-futuna western-sahara)

country_group_ukot = %w(anguilla bermuda british-dependent-territories-citizen british-overseas-citizen british-protected-person british-virgin-islands cayman-islands falkland-islands montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

country_group_non_visa_national = %w(andorra antigua-and-barbuda argentina aruba australia bahamas barbados belize bonaire-st-eustatius-saba botswana brazil british-national-overseas brunei canada chile costa-rica curacao dominica timor-leste el-salvador grenada guatemala honduras hong-kong hong-kong-(british-national-overseas) israel japan kiribati south-korea macao malaysia maldives marshall-islands mauritius mexico micronesia monaco namibia nauru new-zealand nicaragua palau panama papua-new-guinea paraguay st-kitts-and-nevis st-lucia st-maarten st-vincent-and-the-grenadines samoa san-marino seychelles singapore solomon-islands tonga trinidad-and-tobago tuvalu usa uruguay vanuatu vatican-city)

country_group_visa_national = %w(armenia azerbaijan bahrain benin bhutan bosnia-and-herzegovina burkina-faso cambodia cape-verde central-african-republic chad comoros cuba djibouti dominican-republic equatorial-guinea fiji gabon georgia guyana haiti indonesia jordan kazakhstan north-korea kuwait kyrgyzstan laos madagascar mali mauritania morocco mozambique niger oman peru philippines qatar russia sao-tome-and-principe saudi-arabia suriname tajikistan taiwan thailand togo tunisia turkmenistan ukraine united-arab-emirates uzbekistan zambia)

country_group_datv = %w(afghanistan albania algeria angola bangladesh belarus bolivia burma burundi cameroon china colombia congo cyprus-north democratic-republic-of-congo ecuador egypt eritrea ethiopia gambia ghana guinea guinea-bissau india iran iraq cote-d-ivoire jamaica kenya kosovo lebanon lesotho liberia libya macedonia malawi moldova mongolia montenegro nepal nigeria the-occupied-palestinian-territories pakistan rwanda senegal serbia sierra-leone somalia south-africa south-sudan sri-lanka sudan swaziland syria tanzania turkey uganda venezuela vietnam yemen zimbabwe)

country_group_eea = %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia finland france germany greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

# Q1
country_select :what_passport_do_you_have?, :additional_countries => additional_countries, :exclude_countries => exclude_countries do
  save_input_as :passport_country


  next_node do |response|
    if country_group_eea.include?(response)
  	 :outcome_no_visa_needed
    else
      :purpose_of_visit?
    end
  end
end

# Q2
multiple_choice :purpose_of_visit? do
  option :tourism
  option :work
  option :study
  option :transit
  option :family
  option :marriage
  option :school
  option :medical
  save_input_as :purpose_of_visit_answer

  calculate :reason_of_staying do
    if responses.last == 'study'
      PhraseList.new(:study_reason)
    elsif responses.last == 'work'
      PhraseList.new(:work_reason)
    end
  end
  
  next_node do |response|
    case response
    when 'study'
      :staying_for_how_long?
    when 'work'
      :staying_for_how_long?
    when 'tourism'
      if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
        :outcome_visit_waiver
      elsif %w(taiwan).include?(passport_country)
          :outcome_taiwan_exception
      elsif country_group_non_visa_national.include?(passport_country) or
         country_group_ukot.include?(passport_country)
        :outcome_school_n
      else
        :outcome_general_y
      end
    when 'school'
      if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
        :outcome_visit_waiver
      elsif %w(taiwan).include?(passport_country)
        :outcome_taiwan_exception
      elsif country_group_non_visa_national.include?(passport_country) or
         country_group_ukot.include?(passport_country)
        :outcome_school_n
      else
        :outcome_school_y
      end
    when 'marriage'
      :outcome_marriage
    when 'medical'
      if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
        :outcome_visit_waiver
      elsif %w(taiwan).include?(passport_country)
        :outcome_taiwan_exception
      elsif country_group_non_visa_national.include?(passport_country) or
         country_group_ukot.include?(passport_country)
        :outcome_medical_n
      else
        :outcome_medical_y
      end
    when 'transit'

      if country_group_datv.include?(passport_country) or
         country_group_visa_national.include?(passport_country) or %w(taiwan venezuela).include?(passport_country)
        :planning_to_leave_airport?
      else
        :outcome_no_visa_needed
      end
    when 'family'
      if country_group_ukot.include?(passport_country)
        :outcome_joining_family_m
      else
        :outcome_joining_family_y
      end
    end
  end
end

#Q3
multiple_choice :planning_to_leave_airport? do
  option :yes
  option :no
  save_input_as :leaving_airport_answer

  next_node do |response|

    if %w(venezuela taiwan).include?(passport_country)
      :outcome_visit_waiver
    else
      case response
      when 'yes'
        if country_group_visa_national.include?(passport_country)
          :outcome_transit_leaving_airport
        elsif country_group_datv.include?(passport_country)
          :outcome_transit_leaving_airport_datv
        end
      when 'no'
        if country_group_datv.include?(passport_country)
          :outcome_transit_not_leaving_airport
        elsif country_group_visa_national.include?(passport_country)
          :outcome_no_visa_needed
        end
      end
    end
  end
end

#Q4
multiple_choice :staying_for_how_long? do
  option :six_months_or_less
  option :longer_than_six_months

  next_node do |response|
    case response
    when 'longer_than_six_months'
      if purpose_of_visit_answer == 'study'
        :outcome_study_y #outcome 2 study y 
      elsif purpose_of_visit_answer == 'work'
        :outcome_work_y #outcome 4 work y 
      end
    when 'six_months_or_less'
      if purpose_of_visit_answer == 'study'
        if %w(venezuela oman qatar united-arab-emirates).include?(passport_country)
          :outcome_visit_waiver #outcome 12 visit outcome_visit_waiver
        elsif %w(taiwan).include?(passport_country)
          :outcome_taiwan_exception
        elsif (country_group_datv + country_group_visa_national).include?(passport_country) 
          :outcome_study_m #outcome 3 study m visa needed short courses 
        elsif (country_group_ukot + country_group_non_visa_national).include?(passport_country)
          :outcome_no_visa_needed #outcome 1 no visa needed
        end
        
      elsif purpose_of_visit_answer == 'work' 
        if (country_group_datv + country_group_visa_national).include?(passport_country) 
          :outcome_work_m #outcome 5 work m visa needed short courses
        elsif (country_group_ukot + country_group_non_visa_national).include?(passport_country)
          :outcome_work_n #outcome 5.5 work N no visa needed
        end
      end
    end
  end                    
end


outcome :outcome_no_visa_needed do
  precalculate :no_visa_additional_sentence do
    if %w(croatia).include?(passport_country)
      PhraseList.new(:croatia_additional_sentence)
    elsif purpose_of_visit_answer == 'study'
      PhraseList.new(:study_additional_sentence)
    end
  end
end
outcome :outcome_study_y
outcome :outcome_study_m 
outcome :outcome_work_y do
  precalculate :if_youth_mobility_scheme_country do
    if %w(australia canada japan monaco new-zealand hong-kong south-korea taiwan).include?(passport_country)
      PhraseList.new(:youth_mobility_scheme)
    end
  end
  precalculate :if_turkey do
    if %w(turkey).include?(passport_country)
      PhraseList.new(:turkey_business_person_visa)
    end
  end
end
outcome :outcome_work_m 
outcome :outcome_work_n
outcome :outcome_transit_leaving_airport
outcome :outcome_transit_not_leaving_airport
outcome :outcome_joining_family_y
outcome :outcome_joining_family_m
outcome :outcome_visit_business_n
outcome :outcome_general_y do
  precalculate :if_china do
    if %w(china).include?(passport_country)
      PhraseList.new(:china_tour_group)
    end
  end
end
outcome :outcome_business_y
outcome :outcome_marriage
outcome :outcome_school_n
outcome :outcome_school_y
outcome :outcome_medical_y
outcome :outcome_medical_n
outcome :outcome_visit_waiver do
  precalculate :if_exception do
    if %w(venezuela).include?(passport_country)
      if leaving_airport_answer == "yes"
        PhraseList.new(:epassport_crossing_border)
      elsif leaving_airport_answer == "no"
        PhraseList.new(:epassport_not_crossing_border)
      else
        PhraseList.new(:extra_documents)
      end
    elsif %w(taiwan).include?(passport_country)
      if leaving_airport_answer == "yes"
        PhraseList.new(:passport_bio_crossing_border)
      else
        PhraseList.new(:passport_bio_not_crossing_border)
      end
    elsif %w(oman qatar united-arab-emirates).include?(passport_country)
      PhraseList.new(:electronic_visa_waiver)
    end
  end
end
outcome :outcome_transit_leaving_airport_datv
outcome :outcome_taiwan_exception
