module SmartAnswer
  class SmartAnswersControllerSampleWithCountryQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-country-question"
      country_select :country? do
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
