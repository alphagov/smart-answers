class RegisterADeathFlow < SmartAnswer::Flow
  def define
    content_id "9e3af3d4-f044-4ac5-830e-d604d701695b"
    name "register-a-death"
    status :published

    # Q1
    radio :where_did_the_death_happen? do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::RegisterADeathCalculator.new
        calculator.location_of_death = response
      end

      option :england_wales
      option :scotland
      option :northern_ireland
      option :overseas

      next_node do
        if calculator.died_in_uk?
          case calculator.location_of_death
          when "scotland"
            outcome :scotland_result
          when "northern_ireland"
            outcome :northern_ireland_result
          else
            question :did_the_person_die_at_home_hospital?
          end
        else
          outcome :death_abroad_result
        end
      end
    end

    # Q2
    radio :did_the_person_die_at_home_hospital? do
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
    radio :was_death_expected? do
      option :yes
      option :no

      on_response do |response|
        calculator.death_expected = response
      end

      next_node do
        outcome :uk_result
      end
    end

    outcome :uk_result
    outcome :scotland_result
    outcome :northern_ireland_result
    outcome :death_abroad_result
  end
end
