class SessionAnswersController < ApplicationController
  layout "session_answers"

  # rescue_from SessionFlow::FlowNotFoundError, with: :error_404
  # rescue_from SessionFlow::NodeNotFoundError, with: :error_404

  def index
    session[flow_name] = nil
  end

  def show
    form
    flow
  end

  def update
    if form.save
      redirect_to session_flow_path(flow_name, flow.next_node)
    else
      render :show
    end
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
    @form ||= FormFinder.call(flow_name, node_name, params, session)
  end

  def flow
    @flow ||= SessionFlow.call(flow_name, node_name, session[flow_name])
  end
end
