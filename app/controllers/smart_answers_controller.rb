class SmartAnswersController < ApplicationController
  include Slimmer::Headers

  before_action :find_smart_answer, except: %w[index]
  before_action :redirect_response_to_canonical_path, only: %w[show]
  before_action :redirect_query_parameter_flows, only: %w[show]
  before_action :setup_content_item, except: %w[index]

  attr_accessor :content_item

  rescue_from SmartAnswer::FlowRegistry::NotFound, with: :error_404
  rescue_from SmartAnswer::InvalidNode, with: :error_404

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

    render page_type, formats: [:html]

    set_expiry
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

  def redirect_query_parameter_flows
    if @presenter.response_store == :query_parameters
      redirect_to flow_path(
        id: params[:id],
        node_slug: @presenter.state.current_node_name,
        params: @presenter.state.accepted_responses,
      )
    end
  end

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

  def set_expiry(duration = 30.minutes)
    if Rails.configuration.set_http_cache_control_expiry_time
      expires_in(duration, public: true)
    end
  end

  def setup_content_item
    @content_item = ContentItemRetriever.fetch(params[:id])
  end
end
