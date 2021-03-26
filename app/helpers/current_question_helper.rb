module CurrentQuestionHelper
  def current_question_path(presenter)
    if presenter.response_store == :session
      flow_question_path(presenter)
    else
      smart_answers_question_path(presenter)
    end
  end

  def smart_answers_question_path(presenter)
    attrs = params.permit(:id, :started).to_h.symbolize_keys
    attrs[:responses] = presenter.accepted_responses if presenter.accepted_responses.any?
    smart_answer_path(attrs)
  end

  def flow_question_path(presenter)
    node_name = presenter.current_state.current_node.to_s
    update_flow_path(id: params[:id], node_slug: node_name.dasherize)
  end

  def restart_flow_path(presenter)
    if presenter.response_store == :session
      destroy_flow_path(presenter.name)
    else
      smart_answer_path(presenter.name)
    end
  end

  def prefill_value_is?(value)
    if params[:previous_response]
      params[:previous_response] == value
    elsif params[:response]
      params[:response] == value
    end
  end

  def prefill_value_includes?(question, value)
    if params[:previous_response]
      question.to_response(params[:previous_response]).include?(value)
    elsif params[:response]
      params[:response].include?(value)
    end
  end

  def default_for_date(value)
    integer = Integer(value)
    integer.to_s == value.to_s ? integer : nil
  rescue StandardError
    nil
  end

  def prefill_value_for(question, attribute = nil)
    if params[:previous_response]
      response = question.to_response(params[:previous_response])
    elsif params[:response]
      response = params[:response]
    end
    if response.present? && attribute
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
