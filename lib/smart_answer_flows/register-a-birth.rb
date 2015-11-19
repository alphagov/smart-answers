module SmartAnswer
  class RegisterABirthFlow < Flow
    def define
      content_id "bb68ca88-b56b-4df2-a33d-3aaec66a5098"
      name 'register-a-birth'
      status :published
      satisfies_need "101003"

      use_erb_templates_for_questions

      country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
      reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      translator_query = SmartAnswer::Calculators::TranslatorLinks.new
      exclude_countries = %w(holy-see british-antarctic-territory)

      # Q1
      country_select :country_of_birth?, exclude_countries: exclude_countries do
        save_input_as :country_of_birth

        calculate :registration_country do |response|
          reg_data_query.registration_country_slug(response)
        end

        calculate :registration_country_name_lowercase_prefix do
          country_name_query.definitive_article(registration_country)
        end

        next_node_calculation :country_has_no_embassy do |response|
          %w(iran syria yemen).include?(response)
        end

        next_node_calculation :responded_with_commonwealth_country do |response|
          Calculators::RegistrationsDataQuery::COMMONWEALTH_COUNTRIES.include?(response)
        end

        permitted_next_nodes = [
          :commonwealth_result,
          :no_embassy_result,
          :who_has_british_nationality?
        ]
        next_node(permitted: permitted_next_nodes) do
          if country_has_no_embassy
            :no_embassy_result
          elsif responded_with_commonwealth_country
            :commonwealth_result
          else
            :who_has_british_nationality?
          end
        end
      end

      # Q2
      multiple_choice :who_has_british_nationality? do
        option :mother
        option :father
        option :mother_and_father
        option :neither

        save_input_as :british_national_parent

        permitted_next_nodes = [
          :married_couple_or_civil_partnership?,
          :no_registration_result
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'mother', 'father', 'mother_and_father'
            :married_couple_or_civil_partnership?
          when 'neither'
            :no_registration_result
          end
        end
      end

      # Q3
      multiple_choice :married_couple_or_civil_partnership? do
        option :yes
        option :no

        calculate :paternity_declaration do |response|
          response == 'no'
        end

        permitted_next_nodes = [
          :childs_date_of_birth?,
          :where_are_you_now?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'no' && british_national_parent == 'father'
            :childs_date_of_birth?
          else
            :where_are_you_now?
          end
        end
      end

      # Q4
      date_question :childs_date_of_birth? do
        from { Date.today.end_of_year }
        to { 50.years.ago(Date.today) }

        next_node_calculation :before_july_2006 do |response|
          Date.new(2006, 07, 01) > response
        end

        permitted_next_nodes = [
          :homeoffice_result,
          :where_are_you_now?
        ]
        next_node(permitted: permitted_next_nodes) do
          if before_july_2006
            :homeoffice_result
          else
            :where_are_you_now?
          end
        end
      end

      # Q5
      multiple_choice :where_are_you_now? do
        option :same_country
        option :another_country
        option :in_the_uk

        calculate :same_country do |response|
          response == 'same_country'
        end

        calculate :another_country do |response|
          response == 'another_country'
        end

        calculate :in_the_uk do |response|
          response == 'in_the_uk'
        end

        next_node_calculation(:no_birth_certificate_exception) {
          reg_data_query.has_birth_registration_exception?(country_of_birth) & paternity_declaration
        }

        next_node_calculation(:born_in_north_korea) {
          country_of_birth == 'north-korea'
        }

        permitted_next_nodes = [
          :no_birth_certificate_result,
          :north_korea_result,
          :oru_result,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if no_birth_certificate_exception
            :no_birth_certificate_result
          elsif response == 'another_country'
            :which_country?
          elsif response == 'same_country' && born_in_north_korea
            :north_korea_result
          else
            :oru_result
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

        permitted_next_nodes = [
          :north_korea_result,
          :oru_result
        ]
        next_node(permitted: permitted_next_nodes) do
          if currently_in_north_korea
            :north_korea_result
          else
            :oru_result
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
          if organisations.present?
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
          {text: "Pay now", url: "https://pay-register-birth-abroad.service.gov.uk/start"}
        end

        precalculate :custom_waiting_time do
          reg_data_query.custom_registration_duration(country_of_birth)
        end

        precalculate :born_in_lower_risk_country do
          reg_data_query.class::HIGHER_RISK_COUNTRIES.exclude?(country_of_birth)
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
          if organisations and organisations.any?
            service_title = 'Births and Deaths registration service'
            organisations.first.offices_with_service(service_title)
          else
            []
          end
        end

        precalculate :translator_link_url do
          translator_query.links[country_of_birth]
        end
      end

      outcome :commonwealth_result
      outcome :no_registration_result
      outcome :no_embassy_result
      outcome :homeoffice_result
      outcome :no_birth_certificate_result do

        precalculate :location do
          loc = WorldLocation.find(country_of_birth)
          raise InvalidResponse unless loc
          loc
        end

        precalculate :organisations do
          [location.fco_organisation]
        end

        precalculate :overseas_passports_embassies do
          if organisations and organisations.any?
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
