module SmartAnswer
  class RegisterADeathFlow < Flow
    def define
      content_id "9e3af3d4-f044-4ac5-830e-d604d701695b"
      name 'register-a-death'
      status :published
      satisfies_need "101006"

      country_name_query = Calculators::CountryNameFormatter.new
      reg_data_query = Calculators::RegistrationsDataQuery.new
      translator_query = Calculators::TranslatorLinks.new
      exclude_countries = %w(holy-see british-antarctic-territory)

      # Q1
      multiple_choice :where_did_the_death_happen? do
        on_response do |response|
          self.calculator = Calculators::RegisterADeathCalculator.new
          calculator.location_of_death = response
        end

        option :england_wales
        option :scotland
        option :northern_ireland
        option :overseas

        next_node do
          if calculator.died_in_uk?
            question :did_the_person_die_at_home_hospital?
          else
            question :which_country?
          end
        end
      end

      # Q2
      multiple_choice :did_the_person_die_at_home_hospital? do
        option :at_home_hospital
        option :elsewhere

        on_response do |response|
          calculator.death_location_type = response
        end

        next_node do
          question :was_death_expected?
        end
      end

      # Q3
      multiple_choice :was_death_expected? do
        option :yes
        option :no

        on_response do |response|
          calculator.death_expected = response
        end

        next_node do
          outcome :uk_result
        end
      end

      # Q4
      country_select :which_country?, exclude_countries: exclude_countries do
        on_response do |response|
          calculator.country_of_death = response
        end

        calculate :registration_country do
          calculator.registration_country
        end

        calculate :registration_country_name_lowercase_prefix do
          country_name_query.definitive_article(calculator.country_of_death)
        end

        calculate :death_country_name_lowercase_prefix do
          registration_country_name_lowercase_prefix
        end

        next_node_calculation :responded_with_commonwealth_country do
          Calculators::RegistrationsDataQuery::COMMONWEALTH_COUNTRIES.include?(calculator.country_of_death)
        end

        next_node do
          if responded_with_commonwealth_country
            outcome :commonwealth_result
          elsif calculator.country_has_no_embassy?
            outcome :no_embassy_result
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

        calculate :another_country do |response|
          response == 'another_country'
        end

        calculate :in_the_uk do |response|
          response == 'in_the_uk'
        end

        next_node_calculation(:died_in_north_korea) {
          calculator.country_of_death == 'north-korea'
        }

        next_node do |response|
          if response == 'same_country' && died_in_north_korea
            outcome :north_korea_result
          elsif response == 'another_country'
            question :which_country_are_you_in_now?
          else
            outcome :oru_result
          end
        end
      end

      # Q6
      country_select :which_country_are_you_in_now?, exclude_countries: exclude_countries do
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

      outcome :commonwealth_result
      outcome :no_embassy_result

      outcome :uk_result

      outcome :oru_result do
        precalculate :button_data do
          { text: "Pay now", url: "https://pay-register-death-abroad.service.gov.uk/start" }
        end

        precalculate :translator_link_url do
          translator_query.links[calculator.country_of_death]
        end

        precalculate :reg_data_query do
          Calculators::RegistrationsDataQuery.new
        end

        precalculate :document_return_fees do
          reg_data_query.document_return_fees
        end
      end

      outcome :north_korea_result do
        precalculate :reg_data_query do
          Calculators::RegistrationsDataQuery.new
        end

        precalculate :overseas_passports_embassies do
          location = WorldLocation.find(registration_country)
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
