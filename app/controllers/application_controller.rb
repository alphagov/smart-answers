class ApplicationController < ActionController::Base
  rescue_from GdsApi::TimedOutException, with: :error_503
  rescue_from GdsApi::HTTPForbidden, with: :error_403
  rescue_from ActionController::UnknownFormat, with: :error_404
  rescue_from SmartAnswer::FlowRegistry::NotFound, SmartAnswer::InvalidTransition, with: :error_404

  if ENV["BASIC_AUTH_USERNAME"] && ENV["BASIC_AUTH_PASSWORD"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

protected

  def debug?
    Rails.env.development? && params[:debug]
  end
  helper_method :debug?

  def error_403
    error(403)
  end

  def error_404
    error(404)
  end

  def error_503(exception = nil)
    error(503, exception)
  end

  def error(status_code, exception = nil)
    if exception
      GovukError.notify(exception)
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
