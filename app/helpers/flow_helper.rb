module FlowHelper
  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(params[:id])
  end

  def response_store
    @response_store ||= if flow.response_store == :session
                          SessionResponseStore.new(flow_name: params[:id], session: session)
                        else
                          allowable_keys = flow.nodes.map(&:name)
                          query_parameters = request.query_parameters.slice(*allowable_keys)
                          ResponseStore.new(responses: query_parameters)
                        end
  end

  def content_item
    @content_item ||= ContentItemRetriever.fetch(flow.name)
  end

private

  def node_name
    @node_name ||= if params[:node_slug].present?
                     params[:node_slug].underscore
                   else
                     flow.nodes.first.slug
                   end
  end
end
