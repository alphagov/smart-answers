class FlowController < ApplicationController
  include FlowHelper

  before_action :set_cache_headers
  before_action :redirect_path_based_flows, except: :landing

  def landing
    @presenter = FlowPresenter.new(flow, nil)
    @title = @presenter.title

    render @presenter.start_node.view_template_path, formats: [:html]
  end

  def start
    response_store.clear_user_responses
    redirect_to flow_path(id: params[:id],
                          node_slug: flow.questions.first.slug,
                          params: response_store.forwarding_responses)
  end

  def show
    state = SmartAnswer::StateResolver.new(flow).state_from_response_store(response_store, node_name)
    @presenter = FlowPresenter.new(flow, state)
    @title = @presenter.title

    if params[:node_slug] == @presenter.node_slug
      render @presenter.current_node.view_template_path, formats: [:html]
    else
      redirect_to flow_path(id: params[:id],
                            node_slug: @presenter.node_slug,
                            params: response_store.forwarding_responses)
    end
  end

  def update
    response_store.add(node_name, params.fetch(:response, ""))
    state = SmartAnswer::StateResolver.new(flow).state_from_response_store(response_store)
    presenter = FlowPresenter.new(flow, state)
    redirect_to flow_path(id: params[:id],
                          node_slug: presenter.node_slug,
                          params: response_store.forwarding_responses)
  end

  def destroy
    response_store.clear
    redirect_to "/#{params[:id]}"
  end

private

  def redirect_path_based_flows
    redirect_to smart_answer_path(params[:id]) if flow.response_store.nil?
  end

  def set_cache_headers
    if flow.response_store == :session
      response.headers["Cache-Control"] = "no-store"
    elsif Rails.configuration.set_http_cache_control_expiry_time
      expires_in(5.minutes, public: true)
    end
  end
end
