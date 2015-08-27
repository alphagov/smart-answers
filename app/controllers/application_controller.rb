require "slimmer/headers"

class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::Template
  include Slimmer::SharedTemplates
  before_action :set_analytics_headers

  rescue_from GdsApi::TimedOutException, with: :error_503
  rescue_from ActionController::UnknownFormat, with: :error_404

  slimmer_template 'wrapper'

protected

  def error_404; error(404); end

  def error_503(e = nil); error(503, e); end

  def error(status_code, exception = nil)
    if exception and defined? Airbrake
      env["airbrake.error_id"] = notify_airbrake(exception)
    end
    render status: status_code, text: "#{status_code} error"
  end

  def set_analytics_headers
    set_slimmer_headers(format: "smart_answer")
  end
end
