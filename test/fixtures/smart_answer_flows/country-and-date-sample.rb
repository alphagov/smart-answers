module SmartAnswer
  class CountryAndDateSampleFlow < Flow
    def define
      name 'country-and-date-sample'
      status :draft

      use_erb_templates_for_questions

      country_select :which_country_do_you_live_in?, exclude_countries: %w(afghanistan united-kingdom) do
        save_input_as :country
        next_node :what_date_did_you_move_there?
      end

      date_question :what_date_did_you_move_there? do
        from { Date.parse('1900-01-01') }
        to { Date.today }

        save_input_as :date_moved
        calculate :years_there do
          ((Date.today - date_moved) / 365.25).to_i
        end

        next_node :which_country_were_you_born_in?
      end

      country_select :which_country_were_you_born_in?, include_uk: true do
        save_input_as :birth_country
        next_node :ok
      end

      outcome :ok
    end
  end
end
