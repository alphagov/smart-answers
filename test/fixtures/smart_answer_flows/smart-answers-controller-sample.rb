module SmartAnswer
  class SmartAnswersControllerSampleFlow < Flow
    def define
      name "smart-answers-controller-sample"
      satisfies_need 1337

      multiple_choice :do_you_like_chocolate? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :you_have_a_sweet_tooth
          when 'no'
            question :do_you_like_jam?
          end
        end
      end

      multiple_choice :do_you_like_jam? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :you_have_a_sweet_tooth
          when 'no'
            outcome :you_have_a_savoury_tooth
          end
        end
      end

      outcome :you_have_a_savoury_tooth
      outcome :you_have_a_sweet_tooth
    end
  end
end
