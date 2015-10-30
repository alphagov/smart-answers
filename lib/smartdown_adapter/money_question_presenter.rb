module SmartdownAdapter
  class MoneyQuestionPresenter < SmartdownAdapter::QuestionPresenter
    def to_response(input)
      input
    end

    def suffix_label
      nil
    end

  end
end
