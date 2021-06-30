module SmartAnswer
  class SmartAnswersControllerSampleWithPostcodeQuestionFlow < Flow
    def define
      name "smart-answers-controller-sample-with-postcode-question"

      start_page
      postcode_question :postcode? do
        next_node do
          outcome :done
        end
      end
      outcome :done
    end
  end
end
