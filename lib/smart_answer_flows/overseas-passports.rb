module SmartAnswer
  class OverseasPassportsFlow < Flow
    def define
      name 'overseas-passports'
      status :published
      satisfies_need "100131"

      data_query = Calculators::PassportAndEmbassyDataQuery.new

      exclude_countries = %w(holy-see british-antarctic-territory)

      # Q1
      country_select :which_country_are_you_in?, exclude_countries: exclude_countries do
        save_input_as :current_location

        calculate :location do
          loc = WorldLocation.find(current_location)
          if Calculators::PassportAndEmbassyDataQuery::ALT_EMBASSIES.has_key?(current_location)
            loc = WorldLocation.find(Calculators::PassportAndEmbassyDataQuery::ALT_EMBASSIES[current_location])
          end
          raise InvalidResponse unless loc
          loc
        end

        next_node_if(:cannot_apply, data_query.ineligible_country?)
        next_node_if(:which_opt?, responded_with('the-occupied-palestinian-territories'))
        next_node_if(:apply_in_neighbouring_country, data_query.apply_in_neighbouring_countries?)
        next_node(:renewing_replacing_applying?)
      end

      # Q1a
      multiple_choice :which_opt? do
        option :gaza
        option :"jerusalem-or-westbank"

        save_input_as :current_location
        next_node :renewing_replacing_applying?
      end

      # Q2
      multiple_choice :renewing_replacing_applying? do
        option :renewing_new
        option :renewing_old
        option :applying
        option :replacing

        save_input_as :application_action

        precalculate :organisation do
          location.fco_organisation
        end

        calculate :overseas_passports_embassies do
          if organisation
            organisation.offices_with_service 'Overseas Passports Service'
          else
            []
          end
        end

        calculate :general_action do |response|
          response =~ /^renewing_/ ? 'renewing' : response
        end

        calculate :passport_data do
          data_query.find_passport_data(current_location)
        end
        calculate :application_type do
          passport_data['type']
        end
        calculate :is_ips_application do
          data_query.ips_application?.call(self, nil)
        end
        calculate :ips_number do
          application_type.split("_")[2] if is_ips_application
        end

        calculate :application_form do
          passport_data['app_form']
        end

        calculate :supporting_documents do
          passport_data['group']
        end

        calculate :application_address do
          passport_data['address']
        end

        calculate :ips_docs_number do
          supporting_documents.split("_")[3] if is_ips_application
        end

        calculate :ips_result_type do
          passport_data['online_application'] ? :ips_application_result_online : :ips_application_result
        end

        data_query.passport_costs.each do |k, v|
          calculate "costs_#{k}".to_sym do
            v
          end
        end

        calculate :waiting_time do
          passport_data[application_action]
        end

        calculate :optimistic_processing_time do
          passport_data['optimistic_processing_time?']
        end

        next_node :child_or_adult_passport?
      end

      # Q3
      multiple_choice :child_or_adult_passport? do
        option :adult
        option :child

        save_input_as :child_or_adult

        on_condition(data_query.ips_application?) do
          next_node_if(:country_of_birth?, variable_matches(:application_action, %w(applying renewing_old)))
          next_node_if(:ips_application_result_online, variable_matches(:ips_result_type, :ips_application_result_online))
          next_node(:ips_application_result)
        end
      end

      # Q4
      country_select :country_of_birth?, include_uk: true, exclude_countries: exclude_countries do
        save_input_as :birth_location

        calculate :application_group do |response|
          data_query.find_passport_data(response)['group']
        end

        calculate :supporting_documents do |response|
          response == 'united-kingdom' ? supporting_documents : application_group
        end

        calculate :ips_docs_number do
          supporting_documents.split("_")[3]
        end

        on_condition(data_query.ips_application?) do
          next_node_if(:ips_application_result_online, variable_matches(:ips_result_type, :ips_application_result_online))
          next_node(:ips_application_result)
        end
      end

      use_outcome_templates

      ## Online IPS Application Result
      outcome :ips_application_result_online do
        precalculate :birth_location do
          birth_location
        end
      end

      ## IPS Application Result
      outcome :ips_application_result do
        precalculate :data_query do
          data_query
        end

        precalculate :birth_location do
          birth_location
        end
      end

      ## No-op outcome.
      outcome :cannot_apply

      outcome :apply_in_neighbouring_country do
        precalculate :title_output do
          location.name
        end
      end
    end
  end
end
