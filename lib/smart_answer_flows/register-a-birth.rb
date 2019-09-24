module SmartAnswer
  class RegisterABirthFlow < Flow
    def define
      start_page_content_id "bb68ca88-b56b-4df2-a33d-3aaec66a5098"
      flow_content_id "68e9c4da-2edb-4859-8793-17ebc92fc01b"
      name "register-a-birth"
      status :published
      satisfies_need "101003"

      # Q1
      country_select :country_of_birth?, exclude_countries: Calculators::RegisterABirthCalculator::EXCLUDE_COUNTRIES do
        on_response do |response|
          self.calculator = Calculators::RegisterABirthCalculator.new
          calculator.country_of_birth = response
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
          when "mother", "father", "mother_and_father"
            question :married_couple_or_civil_partnership?
          when "neither"
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
          if calculator.paternity_declaration? && calculator.british_national_father?
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
      country_select :which_country?, exclude_countries: Calculators::RegisterABirthCalculator::EXCLUDE_COUNTRIES do
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

      # Outcomes

      outcome :north_korea_result
      outcome :oru_result
      outcome :commonwealth_result
      outcome :no_registration_result
      outcome :no_embassy_result
      outcome :homeoffice_result
      outcome :no_birth_certificate_result
    end
  end
end
