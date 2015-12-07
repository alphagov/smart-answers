module CurrentQuestionHelper
  def calculate_current_question_path(presenter)
    attrs = params.slice(:id, :started).symbolize_keys
    attrs[:responses] = presenter.accepted_responses if presenter.accepted_responses.any?
    smart_answer_path(attrs)
  end

  def previous_response_key(question_number)
    if question_number
      previous_response_key = "previous_response_#{question_number}".to_sym
    else
      previous_response_key = :previous_response
    end
  end

  def prefill_value_is?(value, question_number = nil)
    if params[previous_response_key(question_number)]
      params[previous_response_key(question_number)] == value
    elsif params[:response]
      params[:response] == value
    end
  end

  def prefill_value_includes?(question, value, question_number = nil)
    if params[previous_response_key(question_number)]
      question.to_response(params[previous_response_key(question_number)]).include?(value)
    elsif params[:response]
      params[:response].include?(value)
    end
  end

  def default_for_date(value)
    value.blank? ? nil : value.to_i
  end

  def prefill_value_for(question, attribute = nil)
    question_number = nil
    response = if params[previous_response_key(question_number)]
      question.to_response(params[previous_response_key(question_number)])
    elsif params[:response]
      params[:response]
    end
    if !response.blank? && attribute
      begin
        response[attribute]
      rescue TypeError
        response
      end
    else
      response
    end
  end
end
