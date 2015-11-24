module SmartAnswer
  class ApplyTier4VisaFlow < Flow
    def define
      content_id "af23458d-3437-4545-adae-3bd776ceb8f9"
      name 'apply-tier-4-visa'
      status :published
      satisfies_need "101059"

      use_erb_templates_for_questions

      # Q1
      multiple_choice :extending_or_switching? do
        option :extend_general
        option :switch_general
        option :extend_child
        option :switch_child

        save_input_as :type_of_visa

        calculate :extending do
          type_of_visa.start_with?('extend')
        end
        calculate :switching do
          type_of_visa.start_with?('switch')
        end

        next_node(:sponsor_id?)
      end

      #Q2
      value_question :sponsor_id? do

        save_input_as :sponsor_id

        precalculate :data do
          Calculators::StaticDataQuery.new("apply_tier_4_visa_data").data
        end

        next_node_calculation :sponsor_name do |response|
          data["post"].merge(data["online"])[response]
        end

        validate(:error) { sponsor_name.present? }

        calculate :postal_application do |response|
          data["post"].keys.include?(response)
        end
        calculate :online_application do |response|
          data["online"].keys.include?(response)
        end

        next_node(:outcome)
      end

      outcome :outcome
    end
  end
end
