module CurrentQuestionHelper
  def current_question_path
    if response_store
      update_flow_path(id: params[:id], node_slug: node_presenter.slug)
    else
      attrs = params.permit(:id, :started, :responses).to_h.symbolize_keys
      smart_answer_path(attrs)
    end
  end

  def restart_flow_path
    if response_store
      destroy_flow_path(flow.name)
    else
      smart_answer_path(flow.name)
    end
  end
end
