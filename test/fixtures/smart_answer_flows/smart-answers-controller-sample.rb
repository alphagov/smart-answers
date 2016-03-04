module SmartAnswer
  class SmartAnswersControllerSampleFlow < Flow
    def define
      name "smart-answers-controller-sample"
      satisfies_need 1337

      multiple_choice :do_you_like_chocolate? do
        option :yes
        option :no

        permitted_next_nodes = [
          :you_have_a_sweet_tooth,
          :do_you_like_jam?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :you_have_a_sweet_tooth
          when 'no'
            :do_you_like_jam?
          end
        end
      end

      multiple_choice :do_you_like_jam? do
        option :yes
        option :no

        permitted_next_nodes = [
          :you_have_a_sweet_tooth,
          :you_have_a_savoury_tooth
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :you_have_a_sweet_tooth
          when 'no'
            :you_have_a_savoury_tooth
          end
        end
      end

      outcome :you_have_a_savoury_tooth
      outcome :you_have_a_sweet_tooth
    end
  end
end
