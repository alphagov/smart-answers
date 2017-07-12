module SmartAnswer
  class RegisterADeathFlow < Flow
    def define
      start_page_content_id "9e3af3d4-f044-4ac5-830e-d604d701695b"
      flow_content_id "16230cbd-9c81-44ae-9d24-7d8bbabddf88"
      name 'register-a-death'
      status :published
      satisfies_need "101006"

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
            if calculator.location_of_death == 'scotland'
              outcome :scotland_result
            elsif calculator.location_of_death == 'northern_ireland'
              outcome :northern_ireland_result
            else
              question :did_the_person_die_at_home_hospital?
            end
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
      country_select :which_country?, exclude_countries: Calculators::RegisterADeathCalculator::EXCLUDE_COUNTRIES do
        on_response do |response|
          calculator.country_of_death = response
        end

        next_node do
          if calculator.responded_with_commonwealth_country?
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

        on_response do |response|
          calculator.current_location = response
        end

        next_node do
          if calculator.same_country? && calculator.died_in_north_korea?
            outcome :north_korea_result
          elsif calculator.another_country?
            question :which_country_are_you_in_now?
          else
            outcome :oru_result
          end
        end
      end

      # Q6
      country_select :which_country_are_you_in_now?, exclude_countries: Calculators::RegisterADeathCalculator::EXCLUDE_COUNTRIES do
        on_response do |response|
          calculator.current_country = response
        end

        next_node do
          if calculator.currently_in_north_korea?
            outcome :north_korea_result
          else
            outcome :oru_result
          end
        end
      end

      outcome :commonwealth_result
      outcome :no_embassy_result
      outcome :uk_result
      outcome :oru_result
      outcome :north_korea_result
      outcome :scotland_result
      outcome :northern_ireland_result
    end
  end
end
