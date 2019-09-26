class SmartAnswersController < ApplicationController
  include Slimmer::Headers

  before_action :find_smart_answer, except: %w(index)
  before_action :redirect_response_to_canonical_url, only: %w{show}
  before_action :set_header_footer_only, only: %w{visualise}
  before_action :setup_content_item, except: %w(index)

  attr_accessor :content_item

  rescue_from SmartAnswer::FlowRegistry::NotFound, with: :error_404
  rescue_from SmartAnswer::InvalidNode, with: :error_404

  def index
    @flows = flow_registry.flows.sort_by(&:name)
    @title = "Smart Answers Index"
    @content_item = {}
  end

  def show
    @title = @presenter.title

    respond_to do |format|
      format.html do
        render page_type
      end

      format.json do
        render json: ApiPresenter.new(@presenter).as_json
      end

      if Rails.application.config.expose_govspeak
        format.text { render page_type }
      end
    end

    set_expiry
  end

  def visualise
    respond_to do |format|
      format.html {
        @graph_presenter = GraphPresenter.new(@smart_answer)
        @graph_data = @graph_presenter.to_hash
        render layout: "application"
      }
      format.gv {
        render text: GraphvizPresenter.new(@smart_answer).to_gv
      }
    end
  end

private

  def heroku?
    request.host.include? "herokuapp"
  end
  helper_method :heroku?

  def debug?
    Rails.env.development? && params[:debug]
  end
  helper_method :debug?

  def find_smart_answer
    @name = params[:id].to_sym
    @smart_answer = flow_registry.find(@name.to_s)
    @presenter = FlowPresenter.new(request, @smart_answer)
  end

  def flow_registry
    @flow_registry = SmartAnswer::FlowRegistry.instance
  end

  def page_type
    if @presenter.started?
      if @presenter.finished?
        :result
      else
        :question
      end
    else
      :landing
    end
  end

  def redirect_response_to_canonical_url
    if params[:next] && ! @presenter.current_state.error
      set_expiry
      redirect_params = {
        action:   :show,
        id:        @name,
        started:   "y",
        responses: @presenter.current_state.responses,
        protocol:  request.ssl? || Rails.env.production? ? "https" : "http",
      }
      redirect_to redirect_params
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
