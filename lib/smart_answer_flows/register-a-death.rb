module SmartAnswer
  class RegisterADeathFlow < Flow
    def define
      content_id "9e3af3d4-f044-4ac5-830e-d604d701695b"
      name 'register-a-death'
      status :published
      satisfies_need "101006"

      country_name_query = SmartAnswer::Calculators::CountryNameFormatter.new
      reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      translator_query = SmartAnswer::Calculators::TranslatorLinks.new
      exclude_countries = %w(holy-see british-antarctic-territory)

      # Q1
      multiple_choice :where_did_the_death_happen? do
        save_input_as :where_death_happened
        option :england_wales
        option :scotland
        option :northern_ireland
        option :overseas

        permitted_next_nodes = [
          :did_the_person_die_at_home_hospital?,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'england_wales', 'scotland', 'northern_ireland'
            :did_the_person_die_at_home_hospital?
          when 'overseas'
            :which_country?
          end
        end
      end

      # Q2
      multiple_choice :did_the_person_die_at_home_hospital? do
        option :at_home_hospital
        option :elsewhere
        calculate :died_at_home_hospital do |response|
          response == 'at_home_hospital'
        end
        next_node :was_death_expected?
      end

      # Q3
      multiple_choice :was_death_expected? do
        option :yes
        option :no

        calculate :death_expected do |response|
          response == 'yes'
        end

        next_node :uk_result
      end

      # Q4
      country_select :which_country?, exclude_countries: exclude_countries do
        save_input_as :country_of_death

        calculate :current_location do |response|
          reg_data_query.registration_country_slug(response) || response
        end

        calculate :current_location_name_lowercase_prefix do
          country_name_query.definitive_article(country_of_death)
        end

        calculate :death_country_name_lowercase_prefix do
          current_location_name_lowercase_prefix
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
          :where_are_you_now?
        ]
        next_node(permitted: permitted_next_nodes) do
          if responded_with_commonwealth_country
            :commonwealth_result
          elsif country_has_no_embassy
            :no_embassy_result
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

        calculate :another_country do |response|
          response == 'another_country'
        end

        calculate :in_the_uk do |response|
          response == 'in_the_uk'
        end

        next_node_calculation(:died_in_north_korea) {
          country_of_death == 'north-korea'
        }

        permitted_next_nodes = [
          :north_korea_result,
          :oru_result,
          :which_country_are_you_in_now?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'same_country' && died_in_north_korea
            :north_korea_result
          elsif response == 'another_country'
            :which_country_are_you_in_now?
          else
            :oru_result
          end
        end
      end

      # Q6
      country_select :which_country_are_you_in_now?, exclude_countries: exclude_countries do
        calculate :current_location do |response|
          reg_data_query.registration_country_slug(response) || response
        end

        calculate :current_location_name_lowercase_prefix do
          country_name_query.definitive_article(current_location)
        end

        define_predicate(:currently_in_north_korea) {
          response == 'north-korea'
        }

        next_node_if(:north_korea_result, currently_in_north_korea)
        next_node(:oru_result)
      end

      outcome :commonwealth_result
      outcome :no_embassy_result

      outcome :uk_result

      outcome :oru_result do
        precalculate :button_data do
          {text: "Pay now", url: "https://pay-register-death-abroad.service.gov.uk/start"}
        end

        precalculate :translator_link_url do
          translator_query.links[country_of_death]
        end

        precalculate :reg_data_query do
          SmartAnswer::Calculators::RegistrationsDataQuery.new
        end

        precalculate :document_return_fees do
          reg_data_query.document_return_fees
        end
      end

      outcome :north_korea_result do
        precalculate :reg_data_query do
          SmartAnswer::Calculators::RegistrationsDataQuery.new
        end

        precalculate :overseas_passports_embassies do
          location = WorldLocation.find(current_location)
          raise InvalidResponse unless location
          organisation = location.fco_organisation

          if organisation
            organisation.offices_with_service 'Births and Deaths registration service'
          else
            []
          end
        end
      end
    end
  end
end
