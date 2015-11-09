module SmartAnswer
  class CheckUkVisaFlow < Flow
    def define
      content_id "dc1a1744-4089-43b3-b2e3-4e397b6b15b1"
      name 'check-uk-visa'
      status :published
      satisfies_need "100982"

      additional_countries = UkbaCountry.all

      exclude_countries = %w(american-samoa british-antarctic-territory british-indian-ocean-territory french-guiana french-polynesia gibraltar guadeloupe holy-see martinique mayotte new-caledonia reunion st-pierre-and-miquelon the-occupied-palestinian-territories wallis-and-futuna western-sahara)

      country_group_ukot = %w(anguilla bermuda british-dependent-territories-citizen british-overseas-citizen british-protected-person british-virgin-islands cayman-islands falkland-islands montserrat st-helena-ascension-and-tristan-da-cunha south-georgia-and-south-sandwich-islands turks-and-caicos-islands)

      country_group_non_visa_national = %w(andorra antigua-and-barbuda argentina aruba australia bahamas barbados belize bonaire-st-eustatius-saba botswana brazil british-national-overseas brunei canada chile costa-rica curacao dominica timor-leste el-salvador grenada guatemala honduras hong-kong hong-kong-(british-national-overseas) israel japan kiribati south-korea macao malaysia maldives marshall-islands mauritius mexico micronesia monaco namibia nauru new-zealand nicaragua palau panama papua-new-guinea paraguay pitcairn-island st-kitts-and-nevis st-lucia st-maarten st-vincent-and-the-grenadines samoa san-marino seychelles singapore solomon-islands tonga trinidad-and-tobago tuvalu usa uruguay vanuatu vatican-city)

      country_group_visa_national = %w(stateless-or-refugee armenia azerbaijan bahrain benin bhutan bolivia bosnia-and-herzegovina burkina-faso cambodia cape-verde central-african-republic chad colombia comoros cuba djibouti dominican-republic ecuador equatorial-guinea fiji gabon georgia guyana haiti indonesia jordan kazakhstan north-korea kuwait kyrgyzstan laos madagascar mali  montenegro mauritania morocco mozambique niger oman peru philippines qatar russia sao-tome-and-principe saudi-arabia suriname tajikistan taiwan thailand togo tunisia turkmenistan ukraine united-arab-emirates uzbekistan zambia)

      country_group_datv = %w(afghanistan albania algeria angola bangladesh belarus burma burundi cameroon china congo cyprus-north democratic-republic-of-congo egypt eritrea ethiopia gambia ghana guinea guinea-bissau india iran iraq israel-provisional-passport cote-d-ivoire jamaica kenya kosovo lebanon lesotho liberia libya macedonia malawi moldova mongolia nepal nigeria palestinian-territories pakistan rwanda senegal serbia sierra-leone somalia south-africa south-sudan sri-lanka sudan swaziland syria tanzania turkey uganda venezuela vietnam yemen zimbabwe)

      country_group_eea = %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia finland france germany greece hungary iceland ireland italy latvia liechtenstein lithuania luxembourg malta netherlands norway poland portugal romania slovakia slovenia spain sweden switzerland)

      # Q1
      country_select :what_passport_do_you_have?, additional_countries: additional_countries, exclude_countries: exclude_countries do
        save_input_as :passport_country

        permitted_next_nodes = [
          :israeli_document_type?,
          :outcome_no_visa_needed,
          :purpose_of_visit?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'israel'
            :israeli_document_type?
          elsif country_group_eea.include?(response)
            :outcome_no_visa_needed
          else
            :purpose_of_visit?
          end
        end
      end

      # Q1b
      multiple_choice :israeli_document_type? do
        option :"full-passport"
        option :"provisional-passport"

        permitted_next_nodes = [:purpose_of_visit?]
        next_node(permitted: permitted_next_nodes) do |response|
          self.passport_country = 'israel-provisional-passport' if response == 'provisional-passport'
          :purpose_of_visit?
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
        option :diplomatic
        save_input_as :purpose_of_visit_answer

        calculate :reason_of_staying do |response|
          if response == 'study'
            PhraseList.new(:study_reason)
          elsif response == 'work'
            PhraseList.new(:work_reason)
          end
        end

        permitted_next_nodes = [
          :staying_for_how_long?,
          :outcome_diplomatic_business,
          :outcome_visit_waiver,
          :outcome_taiwan_exception,
          :outcome_school_n,
          :outcome_medical_n,
          :outcome_school_y,
          :outcome_standard_visit,
          :outcome_marriage,
          :outcome_medical_y,
          :planning_to_leave_airport?,
          :outcome_no_visa_needed,
          :outcome_joining_family_m,
          :outcome_joining_family_nvn,
          :outcome_joining_family_y
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'work', 'study'
            next :staying_for_how_long?
          when 'diplomatic'
            next :outcome_diplomatic_business
          when 'tourism', 'school', 'medical'
            if %w(oman qatar united-arab-emirates).include?(passport_country)
              next :outcome_visit_waiver
            elsif passport_country == 'taiwan'
              next :outcome_taiwan_exception
            end
          end

          if country_group_non_visa_national.include?(passport_country) or country_group_ukot.include?(passport_country)
            if %w{tourism school}.include?(response)
              next :outcome_school_n
            elsif response == 'medical'
              next :outcome_medical_n
            end
          end

          case response
          when 'school'
            :outcome_school_y
          when 'tourism'
            :outcome_standard_visit
          when 'marriage'
            :outcome_marriage
          when 'medical'
            :outcome_medical_y
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
            elsif country_group_non_visa_national.include?(passport_country)
              :outcome_joining_family_nvn
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

        permitted_next_nodes = [
          :outcome_visit_waiver,
          :outcome_transit_leaving_airport,
          :outcome_transit_leaving_airport_datv,
          :outcome_visit_waiver,
          :outcome_transit_refugee_not_leaving_airport,
          :outcome_transit_not_leaving_airport,
          :outcome_no_visa_needed
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if %w(taiwan).include?(passport_country)
            next :outcome_visit_waiver
          end

          case response
          when 'yes'
            if country_group_visa_national.include?(passport_country)
              :outcome_transit_leaving_airport
            elsif country_group_datv.include?(passport_country)
              :outcome_transit_leaving_airport_datv
            end
          when 'no'
            if %w(venezuela).include?(passport_country)
              :outcome_visit_waiver
            elsif passport_country == 'stateless-or-refugee'
              :outcome_transit_refugee_not_leaving_airport
            elsif country_group_datv.include?(passport_country)
              :outcome_transit_not_leaving_airport
            elsif country_group_visa_national.include?(passport_country)
              :outcome_no_visa_needed
            end
          end
        end
      end

      #Q4
      multiple_choice :staying_for_how_long? do
        option :six_months_or_less
        option :longer_than_six_months
        save_input_as :period_of_staying

        permitted_next_nodes = [
          :outcome_study_y,
          :outcome_work_y,
          :outcome_visit_waiver,
          :outcome_taiwan_exception,
          :outcome_study_m,
          :outcome_no_visa_needed,
          :outcome_work_n,
          :outcome_work_m
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'longer_than_six_months'
            if purpose_of_visit_answer == 'study'
              :outcome_study_y #outcome 2 study y
            elsif purpose_of_visit_answer == 'work'
              :outcome_work_y #outcome 4 work y
            end
          when 'six_months_or_less'
            if purpose_of_visit_answer == 'study'
              if %w(oman qatar united-arab-emirates).include?(passport_country)
                :outcome_visit_waiver #outcome 12 visit outcome_visit_waiver
              elsif %w(taiwan).include?(passport_country)
                :outcome_taiwan_exception
              elsif (country_group_datv + country_group_visa_national).include?(passport_country)
                :outcome_study_m #outcome 3 study m visa needed short courses
              elsif (country_group_ukot + country_group_non_visa_national).include?(passport_country)
                :outcome_no_visa_needed #outcome 1 no visa needed
              end
            elsif purpose_of_visit_answer == 'work'
              if ( (country_group_ukot +
                country_group_non_visa_national) |
                %w(taiwan) ).include?(passport_country)
                #outcome 5.5 work N no visa needed
                :outcome_work_n
              elsif (country_group_datv + country_group_visa_national).include?(passport_country)
                # outcome 5 work m visa needed short courses
                :outcome_work_m
              end
            end
          end
        end
      end

      outcome :outcome_no_visa_needed do
        precalculate :purpose_of_visit_answer do
          purpose_of_visit_answer
        end
      end
      outcome :outcome_study_y
      outcome :outcome_study_m
      outcome :outcome_work_y
      outcome :outcome_work_m
      outcome :outcome_work_n
      outcome :outcome_transit_leaving_airport
      outcome :outcome_transit_not_leaving_airport
      outcome :outcome_joining_family_y
      outcome :outcome_joining_family_m
      outcome :outcome_joining_family_nvn
      outcome :outcome_standard_visit
      outcome :outcome_marriage
      outcome :outcome_school_n
      outcome :outcome_school_y
      outcome :outcome_medical_y
      outcome :outcome_medical_n
      outcome :outcome_visit_waiver
      outcome :outcome_transit_leaving_airport_datv
      outcome :outcome_taiwan_exception
      outcome :outcome_diplomatic_business
      outcome :outcome_transit_refugee_not_leaving_airport
    end
  end
end
