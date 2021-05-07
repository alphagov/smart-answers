module CurrentQuestionHelper
  def current_question_path(presenter)
    if presenter.response_store
      node_name = presenter.current_node.slug
      update_flow_path(id: params[:id], node_slug: node_name)
    else
      attrs = params.permit(:id, :started).to_h.symbolize_keys
      attrs[:responses] = presenter.accepted_responses if presenter.accepted_responses.any?
      smart_answer_path(attrs)
    end
  end

  def restart_flow_path(presenter)
    if presenter.response_store
      destroy_flow_path(presenter.name)
    else
      smart_answer_path(presenter.name)
    end
  end
end
