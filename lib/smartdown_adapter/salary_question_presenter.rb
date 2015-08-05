module SmartdownAdapter
  class SalaryQuestionPresenter < SmartdownAdapter::QuestionPresenter
    def to_response(input)
      split_input = input.split("-")
      {
        amount: split_input[0],
        period: split_input[1],
      }
    rescue
      nil
      end
  end
end
