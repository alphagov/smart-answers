class SessionAnswersController < ApplicationController
  rescue_from SessionFlow::FlowNotFoundError, with: :error_404
  rescue_from SessionFlow::NodeNotFoundError, with: :error_404

  def show
    form
    flow
  end

  def update
    form
    redirect_to session_flow_path(flow_name, flow.next_node)
  end

private

  def flow_name
    params[:flow_name]
  end

  def node_name
    params[:node_name]
  end

  helper_method :flow_name, :node_name

  def form
    @form ||= FormFinder.call(flow_name, node_name)
  end

  def flow
    @flow ||= SessionFlow.call(flow_name, node_name)
  end
end
