class SmartAnswersController < ApplicationController
  before_action :find_smart_answer, except: %w[index]
  before_action :redirect_response_to_canonical_path, only: %w[show]
  before_action :content_item, except: %w[index]

  content_security_policy only: :visualise do |p|
    # The script used to render the visualise tool requires eval execution
    # unfortunately
    p.script_src(*p.script_src, :unsafe_eval)
  end

  def index
    @flows = flow_registry.flows.sort_by(&:name)
    @title = "Smart Answers Index"
    @content_item = {}
  end

  def show
    @title = @presenter.title

    set_expiry
    render page_type, formats: [:html]
  end

  def visualise
    respond_to do |format|
      format.html do
        @graph_presenter = GraphPresenter.new(@smart_answer)
        @title = @presenter.title
        @graph_data = @graph_presenter.to_hash
        render layout: "application"
      end

      format.gv do
        render plain: GraphvizPresenter.new(@smart_answer).to_gv,
               content_type: "text/vnd.graphviz"
      end
    end
  end

private

  def find_smart_answer
    @name = params[:id].to_sym
    @smart_answer = flow_registry.find(@name.to_s)
    state = SmartAnswer::StateResolver.new(@smart_answer).state_from_params(request.params)
    @presenter = FlowPresenter.new(@smart_answer, state)
  end

  def flow_registry
    @flow_registry = SmartAnswer::FlowRegistry.instance
  end

  def page_type
    return :result if @presenter.finished?

    :question
  end
  helper_method :page_type

  def redirect_response_to_canonical_path
    if params[:next] && !@presenter.state.error
      set_expiry
      redirect_to smart_answer_path(@name, responses: @presenter.accepted_responses.values)
    end
  end

  def content_item
    @content_item ||= ContentItemRetriever.fetch(params[:id])
  end

  def set_expiry
    return unless Rails.configuration.set_http_cache_control_expiry_time

    expires_in(
      content_item.dig("cache_control", "max-age") || 5.minutes.to_i,
      public: content_item.fetch("cache_control", {}).fetch("public", true),
    )
  end
end
