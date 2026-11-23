class StepPresenter
  BODY_LIMIT = 6_000

  def initialize(flow, query_parameters)
    @flow = flow
    @query_parameters = query_parameters
    @tool_schema = ToolSchemaPresenter.new(flow)
  end

  def to_hash
    reply = {
      status: flow_presenter.finished? ? "outcome" : "question",
      node: @tool_schema.answer_key(current_node.node_name),
      answered: flow_presenter.accepted_responses.keys.map { |name| @tool_schema.answer_key(name) },
      unused:,
    }

    reply.merge(flow_presenter.finished? ? outcome : question)
  end

private

  def question
    {
      message: current_node.title,
      requestedSchema: @tool_schema.requested_schema(current_node),
      error: current_node.error,
    }
  end

  def outcome
    body = [current_node.body, current_node.next_steps]
      .compact_blank
      .map { |html| Nokogiri::HTML::DocumentFragment.parse(html).text }
      .join("\n\n")
      .gsub(/^[[:blank:]]+|[[:blank:]]+$/, "")
      .gsub(/\n{3,}/, "\n\n")
      .strip

    {
      title: current_node.title,
      body: body.truncate(BODY_LIMIT),
      truncated: body.length > BODY_LIMIT,
      url: flow_presenter.current_node_link(response_store.forwarding_responses),
    }
  end

  def unused
    used = flow_presenter.accepted_responses.keys + [current_node.node_name] + @flow.additional_parameters

    @query_parameters.keys.reject { |key| used.include?(@tool_schema.node_name(key)) }
  end

  def current_node
    flow_presenter.current_node
  end

  def flow_presenter
    @flow_presenter ||= begin
      state = SmartAnswer::StateResolver.new(@flow).state_from_response_store(response_store)
      FlowPresenter.new(@flow, state)
    end
  end

  def response_store
    @response_store ||= QueryParametersResponseStore.new(
      query_parameters: @query_parameters.with_indifferent_access.transform_keys { |key| @tool_schema.node_name(key) || key },
      user_response_keys: @flow.questions.map { |node| node.name.to_s },
      additional_keys: @flow.additional_parameters,
    )
  end
end
