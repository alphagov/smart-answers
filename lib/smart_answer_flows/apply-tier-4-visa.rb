module SmartAnswer
  class ApplyTier4VisaFlow < Flow
    def define
      name 'apply-tier-4-visa'
      status :published
      satisfies_need "101059"

      # Q1
      multiple_choice :extending_or_switching? do
        option :extend_general
        option :switch_general
        option :extend_child
        option :switch_child

        save_input_as :type_of_visa

        calculate :switch_or_extend do
          if %w(extend_general extend_child).include?(type_of_visa)
            "extend"
          else
            "switch"
          end
        end

        calculate :general_or_child do
          if %w(switch_general extend_general).include?(type_of_visa)
            "general"
          else
            "child"
          end
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

        calculate :post_or_online do |response|
          if data["post"].keys.include?(response)
            "post"
          else
            "online"
          end
        end

        next_node(:outcome)
      end

      use_outcome_templates

      outcome :outcome
    end
  end
end

