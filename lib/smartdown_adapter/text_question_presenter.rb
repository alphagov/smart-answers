module SmartdownAdapter
  class TextQuestionPresenter < SmartdownAdapter::QuestionPresenter
    def to_response(input)
      input.strip
    end
  end
end
