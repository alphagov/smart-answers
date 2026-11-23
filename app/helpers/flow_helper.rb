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

private

  def node_name
    @node_name ||= params[:node_slug].underscore if params[:node_slug].present?
  end
end
