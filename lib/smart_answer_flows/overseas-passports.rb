module SmartAnswer
  class OverseasPassportsFlow < Flow
    def define
      content_id "dd113259-fcaf-4e9b-83d5-d1148f33cf34"
      name 'overseas-passports'
      status :published
      satisfies_need "100131"

      data_query = Calculators::PassportAndEmbassyDataQuery.new

      # Q1
      country_select :which_country_are_you_in?, exclude_countries: Calculators::OverseasPassportsCalculator::EXCLUDE_COUNTRIES do
        next_node_calculation :calculator do
          Calculators::OverseasPassportsCalculator.new
        end

        next_node_calculation :current_location do |response|
          calculator.current_location = response
        end

        calculate :location do
          calculator.world_location
        end

        permitted_next_nodes = [
          :cannot_apply,
          :which_opt?,
          :apply_in_neighbouring_country,
          :renewing_replacing_applying?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if calculator.ineligible_country?
            :cannot_apply
          elsif response == 'the-occupied-palestinian-territories'
            :which_opt?
          elsif calculator.apply_in_neighbouring_countries?
            :apply_in_neighbouring_country
          else
            :renewing_replacing_applying?
          end
        end
      end

      # Q1a
      multiple_choice :which_opt? do
        option :gaza
        option :"jerusalem-or-westbank"

        save_input_as :current_location

        permitted_next_nodes = [
          :renewing_replacing_applying?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.current_location = response

          :renewing_replacing_applying?
        end
      end

      # Q2
      multiple_choice :renewing_replacing_applying? do
        option :renewing_new
        option :renewing_old
        option :applying
        option :replacing

        calculate :general_action do |response|
          response =~ /^renewing_/ ? 'renewing' : response
        end

        calculate :passport_data do
          data_query.find_passport_data(calculator.current_location)
        end
        calculate :application_type do
          passport_data['type']
        end
        calculate :is_ips_application do
          %w{ips_application_1 ips_application_2 ips_application_3}.include?(application_type)
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

        calculate :waiting_time do |response|
          passport_data[response]
        end

        calculate :optimistic_processing_time do
          passport_data['optimistic_processing_time?']
        end

        permitted_next_nodes = [
          :child_or_adult_passport?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.application_action = response

          :child_or_adult_passport?
        end
      end

      # Q3
      multiple_choice :child_or_adult_passport? do
        option :adult
        option :child

        save_input_as :child_or_adult

        permitted_next_nodes = [
          :country_of_birth?,
          :ips_application_result_online,
          :ips_application_result
        ]
        next_node(permitted: permitted_next_nodes) do
          if is_ips_application
            if calculator.applying? || calculator.renewing_old?
              :country_of_birth?
            elsif ips_result_type == :ips_application_result_online
              :ips_application_result_online
            else
              :ips_application_result
            end
          end
        end
      end

      # Q4
      country_select :country_of_birth?, include_uk: true, exclude_countries: Calculators::OverseasPassportsCalculator::EXCLUDE_COUNTRIES do
        calculate :application_group do |response|
          data_query.find_passport_data(response)['group']
        end

        calculate :supporting_documents do |response|
          response == 'united-kingdom' ? supporting_documents : application_group
        end

        calculate :ips_docs_number do
          supporting_documents.split("_")[3]
        end

        permitted_next_nodes = [
          :ips_application_result_online,
          :ips_application_result
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          calculator.birth_location = response

          if is_ips_application
            if ips_result_type == :ips_application_result_online
              :ips_application_result_online
            else
              :ips_application_result
            end
          end
        end
      end

      ## Online IPS Application Result
      outcome :ips_application_result_online

      ## IPS Application Result
      outcome :ips_application_result

      ## No-op outcome.
      outcome :cannot_apply

      outcome :apply_in_neighbouring_country
    end
  end
end
