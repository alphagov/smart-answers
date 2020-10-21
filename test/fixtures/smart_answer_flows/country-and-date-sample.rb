module SmartAnswer
  class CountryAndDateSampleFlow < Flow
    def define
      name "country-and-date-sample"
      status :draft

      country_select :which_country_do_you_live_in? do
        on_response do |response|
          self.country = response
        end

        next_node do
          question :what_date_did_you_move_there?
        end
      end

      date_question :what_date_did_you_move_there? do
        from { Date.parse("1900-01-01") }
        to { Time.zone.today }

        on_response do |response|
          self.years_there = ((Time.zone.today - response) / 365.25).to_i
          self.date_moved = response
        end

        next_node do
          question :which_country_were_you_born_in?
        end
      end

      country_select :which_country_were_you_born_in? do
        on_response do |response|
          self.birth_country = response
        end

        next_node do
          outcome :ok
        end
      end

      outcome :ok
    end
  end
end
