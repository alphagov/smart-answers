module SmartAnswer
  class FlowSampleFlow < Flow
    def define
      name 'flow-sample'
      satisfies_need 4242
      content_id "f26e566e-2557-4921-b944-9373c32255f1"

      multiple_choice :hotter_or_colder? do
        option :hotter
        option :colder

        permitted_next_nodes = [
          :hot,
          :frozen?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'hotter'
            :hot
          when 'colder'
            :frozen?
          end
        end
      end

      multiple_choice :frozen? do
        option :yes
        option :no

        permitted_next_nodes = [
          :frozen,
          :cold
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :frozen
          when 'no'
            :cold
          end
        end
      end

      outcome :hot
      outcome :cold
      outcome :frozen
    end
  end
end
