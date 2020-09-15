class SessionAnswersController < ApplicationController
  before_action :set_cache_headers

  def start
    redirect_to session_flow_path(id: params[:id], node_name: next_node_name)
  end

  def show
    @title = presenter.title
    @content_item = ContentItemRetriever.fetch(name) if presenter.finished?
    render "smart_answers/#{page_type}", formats: [:html]
  end

  def update
    add_new_response_to_session
    redirect_to session_flow_path(id: params[:id], node_name: next_node_name)
  end

  def destroy
    session.delete(:responses)

    if params[:ext_r] == "true"
      redirect_to "https://bbc.co.uk/news"
    else
      redirect_to "/#{params[:id]}"
    end
  end

private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
  end

  def presenter
    @presenter ||= begin
      params.merge!(responses: session_store.hash)
      FlowPresenter.new(params, smart_answer)
    end
  end

  def name
    @name ||= params[:id].gsub(/_/, "-").to_sym
  end

  def smart_answer
    @smart_answer ||= flow_registry.find(name.to_s)
  end

  def session_store
    @session_store ||= SessionStore.new(
      flow_name: name,
      current_node: params[:node_name],
      session: session,
    )
  end

  def flow_registry
    SmartAnswer::FlowRegistry.instance
  end

  def add_new_response_to_session
    session_store.add_response(params[:response])
  end

  def page_type
    return :landing if params[:node_name].blank?
    return :result if presenter.finished?

    :question
  end
  helper_method :page_type

  def next_node_name
    presenter.current_state.current_node.to_s
  end

  def debug?
    Rails.env.development? && params[:debug]
  end
  helper_method :debug?
end
