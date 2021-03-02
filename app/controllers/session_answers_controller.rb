class SessionAnswersController < ApplicationController
  before_action :set_cache_headers

  def start
    session_store.clear
    redirect_to session_flow_path(id: params[:id], node_slug: next_node_slug)
  end

  def show
    @title = presenter.title
    @content_item = ContentItemRetriever.fetch(name) if presenter.finished?

    if requested_node_matches_node_determined_from_session_data?
      render "smart_answers/#{page_type}", formats: [:html]
    else
      redirect_to current_path_determined_from_session_data
    end
  end

  def update
    add_new_response_to_session
    redirect_to session_flow_path(id: params[:id], node_slug: next_node_slug)
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

  def requested_node_matches_node_determined_from_session_data?
    params[:node_slug] == presenter.node_slug
  end

  def current_path_determined_from_session_data
    session_flow_path(id: params[:id], node_slug: presenter.node_slug)
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

  def add_new_response_to_session
    session_store.add_response(params[:response])
  end

  def page_type
    return :landing if node_name.blank?
    return :result if presenter.finished?

    :question
  end
  helper_method :page_type

  def next_node_slug
    presenter.current_state.current_node.to_s.dasherize
  end
end
