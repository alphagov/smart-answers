module FlowHelper
  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(params[:id])
  end

  def presenter
    state = SmartAnswer::State.new(response_store.all)

    @presenter ||= FlowPresenter.new(flow, state)
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

private

  def node_name
    @node_name ||= params[:node_slug].underscore if params[:node_slug].present?
  end

  def next_node_slug
    presenter.current_node.slug
  end
end
