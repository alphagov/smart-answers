module CurrentQuestionHelper
  def current_question_path(presenter)
    if presenter.response_store
      update_flow_path(id: presenter.name, node_slug: presenter.node_slug)
    else
      attrs = params.permit(:id).to_h.symbolize_keys
      attrs[:responses] = presenter.accepted_responses.values if presenter.accepted_responses.any?
      smart_answer_path(attrs)
    end
  end

  def restart_flow_path(presenter)
    if presenter.response_store
      destroy_flow_path(presenter.name)
    else
      flow_landing_path(presenter.name)
    end
  end
end
