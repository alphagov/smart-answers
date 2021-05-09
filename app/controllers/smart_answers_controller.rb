class SmartAnswersController < ApplicationController
  include FlowHelper
  include Slimmer::Headers

  before_action :redirect_response_to_canonical_path, only: %w[show]
  before_action :set_header_footer_only, only: %w[visualise]
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
    @flows = SmartAnswer::FlowRegistry.instance.flows.sort_by(&:name)
    @title = "Smart Answers Index"
    @content_item = {}
  end

  def show
    @title = flow.title

    render node_presenter.view_template_path, formats: [:html]

    set_expiry
  end

  def visualise
    respond_to do |format|
      format.html do
        @graph_presenter = GraphPresenter.new(flow)
        @graph_data = @graph_presenter.to_hash
        render layout: "application"
      end

      format.gv do
        render plain: GraphvizPresenter.new(flow).to_gv,
               content_type: "text/vnd.graphviz"
      end
    end
  end

private

  def redirect_response_to_canonical_path
    if params[:next] && !node_presenter.error
      responses = previous_questions.map(&:response).join("/")
      redirect_to smart_answer_path(flow.name, started: "y", responses: responses)
    end
  end

  def set_header_footer_only
    set_slimmer_headers(template: "header_footer_only")
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
