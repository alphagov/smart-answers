class ApplicationController < ActionController::Base
  include Slimmer::Template

  rescue_from GdsApi::TimedOutException, with: :error_503
  rescue_from ActionController::UnknownFormat, with: :error_404

  slimmer_template 'wrapper'

protected

  def error_404; error(404); end

  def error_503(e = nil); error(503, e); end

  def error(status_code, exception = nil)
    if exception && defined? Airbrake
      request.env["airbrake.error_id"] = notify_airbrake(exception)
    end

    error_message = "#{status_code} error"

    # handle cases where exception occured during render
    if performed?
      self.status = status_code
      self.response_body = error_message
    else
      render status: status_code, plain: error_message
    end
  end
end
