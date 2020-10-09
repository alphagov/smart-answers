module SmartAnswer
  class FlowSampleFlow < Flow
    def define
      name "flow-sample"
      satisfies_need "dccab509-bd3b-4f92-9af6-30f88485ac41"
      start_page_content_id "f26e566e-2557-4921-b944-9373c32255f1"

      radio :hotter_or_colder? do
        option :hotter
        option :colder

        next_node do |response|
          case response
          when "hotter"
            outcome :hot
          when "colder"
            question :frozen?
          end
        end
      end

      radio :frozen? do
        option :yes
        option :no

        next_node do |response|
          case response
          when "yes"
            outcome :frozen
          when "no"
            outcome :cold
          end
        end
      end

      outcome :hot
      outcome :cold
      outcome :frozen
    end
  end
end
