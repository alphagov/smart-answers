module SmartAnswer::Calculators
  class UkVisaCalculator
    include ActiveModel::Model

    attr_accessor :passport_country
    attr_accessor :purpose_of_visit_answer
    attr_accessor :passing_through_uk_border_control_answer

    def passport_country_in_eea?
      COUNTRY_GROUP_EEA.include?(passport_country)
    end

    def passport_country_in_non_visa_national_list?
      COUNTRY_GROUP_NON_VISA_NATIONAL.include?(passport_country)
    end

    def passport_country_in_visa_national_list?
      COUNTRY_GROUP_VISA_NATIONAL.include?(passport_country)
    end

    def passport_country_in_ukot_list?
      COUNTRY_GROUP_UKOT.include?(passport_country)
    end

    def passport_country_in_datv_list?
      COUNTRY_GROUP_DATV.include?(passport_country)
    end

    def passport_country_in_youth_mobility_scheme_list?
      COUNTRY_GROUP_YOUTH_MOBILITY_SCHEME.include?(passport_country)
    end

    def passport_country_in_electronic_visa_waiver_list?
      COUNTRY_GROUP_ELECTRONIC_VISA_WAIVER.include?(passport_country)
    end

    def applicant_is_stateless_or_a_refugee?
      passport_country == 'stateless-or-refugee'
    end

    def tourism_visit?
      purpose_of_visit_answer == 'tourism'
    end

    def work_visit?
      purpose_of_visit_answer == 'work'
    end

    def study_visit?
      purpose_of_visit_answer == 'study'
    end

    def transit_visit?
      purpose_of_visit_answer == 'transit'
    end

    def family_visit?
      purpose_of_visit_answer == 'family'
    end

    def marriage_visit?
      purpose_of_visit_answer == 'marriage'
    end

    def school_visit?
      purpose_of_visit_answer == 'school'
    end

    def medical_visit?
      purpose_of_visit_answer == 'medical'
    end

    def diplomatic_visit?
      purpose_of_visit_answer == 'diplomatic'
    end
    
    def passing_through_uk_border_control?
      passing_through_uk_border_control_answer == 'yes'
    end

    EXCLUDE_COUNTRIES = %w(american-samoa british-antarctic-territory british-indian-ocean-territory french-guiana french-polynesia gibraltar guadeloupe holy-see martinique mayotte new-caledonia reunion st-pierre-and-miquelon the-occupied-palestinian-territories wallis-and-futuna western-sahara)

    COUNTRY_GROUP_UKOT = %w(anguilla bermuda british-dependent-territories-citizen british-overseas-citizen british-protected-person british-virgin-islands cayman-islands falkland-islands montserrat st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

    COUNTRY_GROUP_NON_VISA_NATIONAL = %w(andorra antigua-and-barbuda argentina aruba australia bahamas barbados belize bonaire-st-eustatius-saba botswana brazil british-national-overseas brunei canada chile costa-rica curacao dominica timor-leste el-salvador grenada guatemala honduras hong-kong hong-kong-(british-national-overseas) israel japan kiribati south-korea macao malaysia maldives marshall-islands mauritius mexico micronesia monaco namibia nauru new-zealand nicaragua palau panama papua-new-guinea paraguay pitcairn-island st-kitts-and-nevis st-lucia st-maarten st-vincent-and-the-grenadines samoa san-marino seychelles singapore solomon-islands tonga trinidad-and-tobago tuvalu usa uruguay vanuatu vatican-city)

    COUNTRY_GROUP_VISA_NATIONAL = %w(stateless-or-refugee armenia azerbaijan bahrain benin bhutan bolivia bosnia-and-herzegovina burkina-faso cambodia cape-verde central-african-republic chad colombia comoros cuba djibouti dominican-republic ecuador equatorial-guinea fiji gabon georgia guyana haiti indonesia jordan kazakhstan north-korea kuwait kyrgyzstan laos madagascar mali  montenegro mauritania morocco mozambique niger oman peru philippines qatar russia sao-tome-and-principe saudi-arabia suriname tajikistan taiwan thailand togo tunisia turkmenistan ukraine united-arab-emirates uzbekistan zambia)

    COUNTRY_GROUP_DATV = %w(afghanistan albania algeria angola bangladesh belarus burma burundi cameroon china congo cyprus-north democratic-republic-of-congo egypt eritrea ethiopia gambia ghana guinea guinea-bissau india iran iraq israel-provisional-passport cote-d-ivoire jamaica kenya kosovo lebanon lesotho liberia libya macedonia malawi moldova mongolia nepal nigeria palestinian-territories pakistan rwanda senegal serbia sierra-leone somalia south-africa south-sudan sri-lanka sudan swaziland syria tanzania turkey uganda venezuela vietnam yemen zimbabwe)

    COUNTRY_GROUP_EEA = %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia finland france germany greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

    COUNTRY_GROUP_YOUTH_MOBILITY_SCHEME = %w(australia canada japan monaco new-zealand hong-kong south-korea taiwan)

    COUNTRY_GROUP_ELECTRONIC_VISA_WAIVER = %w(oman qatar united-arab-emirates)
  end
end
