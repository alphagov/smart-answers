class SmartAnswersController < ApplicationController
  include Slimmer::GovukComponents
  include Slimmer::Headers
  include EducationNavigationABTestable

  before_action :find_smart_answer, except: %w(index)
  before_action :redirect_response_to_canonical_url, only: %w{show}
  before_action :set_header_footer_only, only: %w{visualise}
  before_filter :setup_navigation_helpers_and_content_item, except: %w(index)

  helper_method :breadcrumbs

  rescue_from SmartAnswer::FlowRegistry::NotFound, with: :error_404
  rescue_from SmartAnswer::InvalidNode, with: :error_404

  def index
    @flows = flow_registry.flows.sort_by(&:name)
  end

  def show
    respond_to do |format|
      format.html { render }
      format.json {
        html_fragment = with_format('html') {
          render_to_string(partial: "content")
        }
        render json: {
          url: smart_answer_path(params[:id], 'y', @presenter.current_state.responses),
          html_fragment: html_fragment,
          title: @presenter.current_node.title
        }
      }
      if Rails.application.config.expose_govspeak
        format.text {
          render
        }
      end
    end

    set_expiry
  end

  def visualise
    respond_to do |format|
      format.html {
        @graph_presenter = GraphPresenter.new(@smart_answer)
        @graph_data = @graph_presenter.to_hash
        render layout: true
      }
      format.gv {
        render text: GraphvizPresenter.new(@smart_answer).to_gv
      }
    end
  end

private

  def debug?
    Rails.env.development? && params[:debug]
  end
  helper_method :debug?

  def json_request?
    request.format == Mime::JSON
  end

  def with_format(format, &block)
    old_formats = self.formats
    self.formats = [format]
    result = block.call
    self.formats = old_formats
    result
  end

  def find_smart_answer
    @name = params[:id].to_sym
    @smart_answer = flow_registry.find(@name.to_s)
    @presenter = FlowPresenter.new(request, @smart_answer)
  end

  def flow_registry
    @flow_registry = SmartAnswer::FlowRegistry.instance
  end

  def redirect_response_to_canonical_url
    if params[:next] && ! @presenter.current_state.error
      set_expiry
      redirect_params = {
        action:   :show,
        id:        @name,
        started:   "y",
        responses: @presenter.current_state.responses,
        protocol:  (request.ssl? || Rails.env.production?) ? 'https' : 'http',
      }
      redirect_to redirect_params
    end
  end

  def set_header_footer_only
    set_slimmer_headers(template: 'header_footer_only')
  end

  def set_expiry(duration = 30.minutes)
    if Rails.configuration.set_http_cache_control_expiry_time
      expires_in(duration, public: true)
    end
  end

  def setup_navigation_helpers_and_content_item
    @content_item = Services.content_store.content_item!("/" + params[:id]).to_hash

    # The GOV.UK analytics component[1] automatically sets `govuk:analytics:organisations`
    # if there's a `organisations` key in the links. This will be sent to Google
    # Analytics At the moment we want to avoid setting this because it will flood
    # the analytics reports with (unexpected) data. We are currently working on
    # a solution to this conundrum[2].
    #
    # [1] http://govuk-component-guide.herokuapp.com/components/analytics_meta_tags
    # [2] https://trello.com/c/DkR63grd
    if @content_item["links"]
      @content_item["links"].delete("organisations")
    end

    @navigation_helpers = GovukNavigationHelpers::NavigationHelper.new(@content_item)
  rescue GdsApi::HTTPNotFound, GdsApi::HTTPGone
    @navigation_helpers = nil
    @content_item = nil
  end

  def breadcrumbs
    return {} if @navigation_helpers.nil?
    if should_present_new_navigation_view?
      @navigation_helpers.taxon_breadcrumbs
    else
      @navigation_helpers.breadcrumbs
    end
  end
end
