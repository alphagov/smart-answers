class FlowController < ApplicationController
  include FlowHelper

  before_action :set_cache_headers
  before_action :redirect_path_based_flows

  def start
    response_store.clear
    redirect_to flow_path(id: params[:id], node_slug: flow.questions.first.slug)
  end

  def show
    @title = flow.title

    if params[:node_slug] == node_presenter.slug
      render node_presenter.view_template_path, formats: [:html]
    else
      redirect_to flow_path(id: params[:id], node_slug: node_presenter.slug, params: forwarding_responses)
    end
  end

  def update
    response_store.add(params[:node_slug].underscore, params.fetch(:response, ""))
    redirect_to flow_path(id: params[:id], node_slug: node_presenter.slug, params: forwarding_responses)
  end

  def destroy
    response_store.clear

    if params[:ext_r] == "true"
      redirect_to "https://www.bbc.co.uk/weather"
    else
      redirect_to "/#{params[:id]}"
    end
  end

private

  def redirect_path_based_flows
    if flow.response_store.nil? && !node_presenter.landing?
      redirect_to smart_answer_path(params[:id], started: "y")
    end
  end

  def set_cache_headers
    if flow.response_store == :session
      response.headers["Cache-Control"] = "private, no-store, max-age=0, must-revalidate"
    elsif Rails.configuration.set_http_cache_control_expiry_time
      expires_in(30.minutes, public: true)
    end
  end
end
