module SmartAnswer
  class ReportALostOrStolenPassportFlow < Flow
    def define
      content_id "f02fc2c9-f5ff-4ea2-acc4-730bbda957bb"
      name 'report-a-lost-or-stolen-passport'
      status :published
      satisfies_need "100221"

      use_erb_templates_for_questions

      exclude_countries = %w(holy-see british-antarctic-territory)

      multiple_choice :where_was_the_passport_lost_or_stolen? do
        option :in_the_uk
        option :abroad

        save_input_as :location

        permitted_next_nodes = [
          :complete_LS01_form,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'in_the_uk'
            :complete_LS01_form
          when 'abroad'
            :which_country?
          end
        end
      end

      country_select :which_country?, exclude_countries: exclude_countries do
        save_input_as :country

        calculate :overseas_passports_embassies do
          location = WorldLocation.find(country)
          raise InvalidResponse unless location
          if location.fco_organisation
            location.fco_organisation.offices_with_service 'Lost or Stolen Passports'
          else
            []
          end

        end

        permitted_next_nodes = [
          :contact_the_embassy,
          :contact_the_embassy_canada
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'canada'
            :contact_the_embassy_canada
          else
            :contact_the_embassy
          end
        end
      end

      outcome :contact_the_embassy
      outcome :contact_the_embassy_canada
      outcome :complete_LS01_form
    end
  end
end
