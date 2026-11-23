module FlowHelper
  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(params[:id])
  end

  def response_store
    @response_store ||= begin
      keys = {
        user_response_keys: flow.questions.map { |node| node.name.to_s },
        additional_keys: flow.additional_parameters,
      }

      if flow.response_store == :session
        SessionResponseStore.new(flow_name: params[:id], session:, **keys)
      else
        QueryParametersResponseStore.new(query_parameters: request.query_parameters, **keys)
      end
    end
  end

  def content_item
    @content_item ||= ContentItemRetriever.fetch(flow.name)
  end

  def webmcp_tool_data(presenter)
    {
      module: "smart-answer-webmcp",
      flow_id: presenter.name,
      tool_name: presenter.name.underscore,
      flow_title: presenter.title,
      input_schema: ToolSchemaPresenter.new(presenter.flow).input_schema,
      output_schema: ToolSchemaPresenter::OUTPUT_SCHEMA,
    }
  end

  def webmcp_finder_data(flows)
    {
      module: "smart-answer-webmcp-finder",
      input_schema: ToolSchemaPresenter::FINDER_INPUT_SCHEMA,
      output_schema: ToolSchemaPresenter::FINDER_OUTPUT_SCHEMA,
      flows: flows.reject { |flow| flow.response_store == :session }.map do |flow|
        start_node = flow.start_node.presenter
        {
          slug: flow.name,
          title: start_node.title,
          description: start_node.meta_description.to_s,
          url: flow_landing_path(flow.name),
        }
      end,
    }
  end

private

  def node_name
    @node_name ||= params[:node_slug].underscore if params[:node_slug].present?
  end
end
