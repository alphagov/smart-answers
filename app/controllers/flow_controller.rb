class FlowController < ApplicationController
  before_action :set_cache_headers
  before_action :redirect_path_based_flows

  def start
    session_store.clear
    redirect_to flow_path(id: params[:id], node_slug: next_node_slug)
  end

  def show
    @title = presenter.title
    @content_item = ContentItemRetriever.fetch(name) if presenter.finished?

    if params[:node_slug] == presenter.node_slug
      render presenter.current_node.view_template_path, formats: [:html]
    else
      redirect_to flow_path(id: params[:id], node_slug: presenter.node_slug)
    end
  end

  def update
    session_store.add_response(params[:response])
    redirect_to flow_path(id: params[:id], node_slug: next_node_slug)
  end

  def destroy
    session_store.clear

    if params[:ext_r] == "true"
      redirect_to "https://www.bbc.co.uk/weather"
    else
      redirect_to "/#{params[:id]}"
    end
  end

private

  def redirect_path_based_flows
    redirect_to smart_answer_path(params[:id], started: "y") if flow.response_store.nil?
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "private, no-store, max-age=0, must-revalidate"
  end

  def presenter
    @presenter ||= begin
      params.merge!(responses: session_store.hash, node_name: node_name)
      FlowPresenter.new(params, flow)
    end
  end

  def name
    @name ||= params[:id].gsub(/_/, "-").to_sym
  end

  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(name.to_s)
  end

  def session_store
    @session_store ||= SessionStore.new(
      flow_name: name,
      current_node: node_name,
      session: session,
    )
  end

  def node_name
    @node_name ||= params[:node_slug].underscore if params[:node_slug].present?
  end

  def next_node_slug
    presenter.current_state.current_node.to_s.dasherize
  end
end
