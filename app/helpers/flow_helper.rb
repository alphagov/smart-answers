module FlowHelper
  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(params[:id])
  end

  def node_presenter
    visited_node_presenters.last
  end

  def visited_node_presenters
    state = start_state
    flow.visited_nodes(state).map { |node| node.presenter(state) }
  end

  def start_state
    requested_node = node_name unless params[:next]
    SmartAnswer::State.new(response_store.all, requested_node)
  end

  def response_store
    @response_store ||= begin
      if flow.response_store == :session
        SessionResponseStore.new(flow_name: params[:id], session: session)
      else
        allowable_keys = flow.nodes.map(&:name)
        query_parameters = request.query_parameters.slice(*allowable_keys)
        ResponseStore.new(responses: query_parameters)
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
    if response_store
      start_flow_path(flow.name)
    else
      smart_answer_path(flow.name, started: "y")
    end
  end

  def previous_questions
    visited_node_presenters.select { |presenter| presenter.question? && presenter.response }
  end

  def change_answer_link(question)
    if response_store
      flow_path(flow.name, node_slug: question.slug, params: {})
    else
      question_index = previous_questions.index { |q| q.node_name == question.node_name }
      responses = previous_questions[..question_index - 1].map(&:response)

      smart_answer_path(
        id: flow.name,
        started: "y",
        responses: responses,
        previous_response: question.response,
      )
    end
  end

private

  def node_name
    @node_name ||= params[:node_slug].underscore if params[:node_slug].present?
  end
end
