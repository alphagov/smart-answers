module FlowHelper
  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(params[:id])
  end

  def node_presenter
    visited_node_presenters.last
  end

  def visited_node_presenters
    @visited_node_presenters ||= begin
      state = SmartAnswer::State.new(response_store.all)
      requested_node = params[:next] || flow.response_store.nil? ? false : params[:node_slug]

      flow.visited_nodes(state, requested_node).map { |node| node.presenter(state) }
    end
  end

  def response_store
    @response_store ||= begin
      if flow.response_store == :session
        SessionResponseStore.new(flow_name: params[:id], session: session)
      elsif flow.response_store == :query_parameters
        allowable_keys = flow.nodes.map(&:name)
        query_parameters = request.query_parameters.slice(*allowable_keys)
        ResponseStore.new(responses: query_parameters)
      else
        responses = params[:responses].to_s.split("/")
        responses << params[:response] if params[:next]
        state = flow.state_from_path(responses)

        ResponseStore.new(responses: state.responses)
      end
    end
  end

  def content_item
    @content_item ||= ContentItemRetriever.fetch(flow.name)
  end

  def forwarding_responses
    flow.response_store == :session ? {} : response_store.all
  end

  def start_page_link
    if flow.response_store
      start_flow_path(flow.name)
    else
      smart_answer_path(flow.name, started: "y")
    end
  end

  def previous_questions
    visited_node_presenters.select do |presenter|
      presenter.question? && !presenter.error && presenter.response && presenter.name != node_presenter.name
    end
  end

  def change_answer_link(question)
    if flow.response_store
      flow_path(flow.name, node_slug: question.slug, params: {})
    else
      question_index = previous_questions.index { |q| q.name == question.name }
      responses = previous_questions[..question_index - 1].map(&:response)

      smart_answer_path(
        id: flow.name,
        started: "y",
        responses: responses,
        previous_response: question.response,
      )
    end
  end
end
