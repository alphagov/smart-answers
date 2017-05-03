module SmartAnswer
  class NationalMinimumWageFlow < Flow
    def define
      content_id 'f2c42b26-eb74-4ba1-88a2-9ef7d8044294'
      name 'national-minimum-wage'

      status :draft
      satisfies_need '100145'

      multiple_choice :what_do_you_want_to_know? do
        option 'current_payment'

        next_node do
          outcome :earning_more_than_living_wage
        end
      end

      outcome :earning_more_than_living_wage
    end
  end
end
