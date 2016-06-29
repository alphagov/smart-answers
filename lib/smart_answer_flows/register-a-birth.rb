module SmartAnswer
  class RegisterABirthFlow < Flow
    def define
      content_id "bb68ca88-b56b-4df2-a33d-3aaec66a5098"
      name 'register-a-birth'
      status :published
      satisfies_need "101003"

      country_name_query = Calculators::CountryNameFormatter.new
      reg_data_query = Calculators::RegistrationsDataQuery.new
      translator_query = Calculators::TranslatorLinks.new
      exclude_countries = %w(holy-see british-antarctic-territory)

      # Q1
      country_select :country_of_birth?, exclude_countries: exclude_countries do
        on_response do |response|
          self.calculator = Calculators::RegisterABirthCalculator.new
          calculator.country_of_birth = response
        end

        calculate :registration_country do
          calculator.registration_country
        end

        calculate :registration_country_name_lowercase_prefix do
          calculator.registration_country_name_lowercase_prefix
        end

        next_node do
          if calculator.country_has_no_embassy?
            outcome :no_embassy_result
          elsif calculator.responded_with_commonwealth_country?
            outcome :commonwealth_result
          else
            question :who_has_british_nationality?
          end
        end
      end

      # Q2
      multiple_choice :who_has_british_nationality? do
        option :mother
        option :father
        option :mother_and_father
        option :neither

        on_response do |response|
          calculator.british_national_parent = response
        end

        next_node do
          case calculator.british_national_parent
          when 'mother', 'father', 'mother_and_father'
            question :married_couple_or_civil_partnership?
          when 'neither'
            outcome :no_registration_result
          end
        end
      end

      # Q3
      multiple_choice :married_couple_or_civil_partnership? do
        option :yes
        option :no

        on_response do |response|
          calculator.married_couple_or_civil_partnership = response
        end

        next_node do
          if calculator.paternity_declaration? && calculator.british_national_parent == 'father'
            question :childs_date_of_birth?
          else
            question :where_are_you_now?
          end
        end
      end

      # Q4
      date_question :childs_date_of_birth? do
        from { Date.today.end_of_year }
        to { 50.years.ago(Date.today) }

        on_response do |response|
          calculator.childs_date_of_birth = response
        end

        next_node do
          if calculator.before_july_2006?
            outcome :homeoffice_result
          else
            question :where_are_you_now?
          end
        end
      end

      # Q5
      multiple_choice :where_are_you_now? do
        option :same_country
        option :another_country
        option :in_the_uk

        on_response do |response|
          calculator.current_location = response
        end

        next_node do
          if calculator.no_birth_certificate_exception?
            outcome :no_birth_certificate_result
          elsif calculator.another_country?
            question :which_country?
          elsif calculator.same_country? && calculator.born_in_north_korea?
            outcome :north_korea_result
          else
            outcome :oru_result
          end
        end
      end

      # Q6
      country_select :which_country?, exclude_countries: exclude_countries do
        calculate :registration_country do |response|
          reg_data_query.registration_country_slug(response)
        end

        calculate :registration_country_name_lowercase_prefix do
          country_name_query.definitive_article(registration_country)
        end

        next_node_calculation(:currently_in_north_korea) {
          response == 'north-korea'
        }

        next_node do
          if currently_in_north_korea
            outcome :north_korea_result
          else
            outcome :oru_result
          end
        end
      end

      # Outcomes

      outcome :north_korea_result do
        precalculate :reg_data_query do
          reg_data_query
        end

        precalculate :overseas_passports_embassies do
          location = WorldLocation.find(registration_country)
          raise InvalidResponse unless location
          organisations = [location.fco_organisation]
          if organisations && organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end
      end

      outcome :oru_result do
        precalculate :reg_data_query do
          reg_data_query
        end

        precalculate :document_return_fees do
          reg_data_query.document_return_fees
        end

        precalculate :button_data do
          { text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start" }
        end

        precalculate :custom_waiting_time do
          reg_data_query.custom_registration_duration(calculator.country_of_birth)
        end

        precalculate :born_in_lower_risk_country do
          reg_data_query.lower_risk_country?(calculator.country_of_birth)
        end

        precalculate :location do
          loc = WorldLocation.find(registration_country)
          raise InvalidResponse unless loc
          loc
        end

        precalculate :organisations do
          [location.fco_organisation]
        end

        precalculate :overseas_passports_embassies do
          if organisations && organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end

        precalculate :translator_link_url do
          translator_query.links[calculator.country_of_birth]
        end
      end

      outcome :commonwealth_result
      outcome :no_registration_result
      outcome :no_embassy_result
      outcome :homeoffice_result
      outcome :no_birth_certificate_result do
        precalculate :location do
          loc = WorldLocation.find(calculator.country_of_birth)
          raise InvalidResponse unless loc
          loc
        end

        precalculate :organisations do
          [location.fco_organisation]
        end

        precalculate :overseas_passports_embassies do
          if organisations && organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end
      end
    end
  end
end
