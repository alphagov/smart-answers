class ApplicationController < ActionController::Base
  include Slimmer::Template

  rescue_from GdsApi::TimedOutException, with: :error_503
  rescue_from ActionController::UnknownFormat, with: :error_404

  slimmer_template 'wrapper'

  helper_method :benchmarking_ab_test
  helper_method :should_track_mouse_movements?

  def benchmarking_ab_test
    @benchmarking_ab_test ||= begin
      benchmarking_test = BenchmarkingAbTestRequest.new(request)
      benchmarking_test.set_response_vary_header(response)
      benchmarking_test
    end
  end

  def should_track_mouse_movements?
    benchmarking_ab_test.in_benchmarking?
  end

protected

  def error_404; error(404); end

  def error_503(e = nil); error(503, e); end

  def error(status_code, exception = nil)
    if exception && defined? Airbrake
      env["airbrake.error_id"] = notify_airbrake(exception)
    end

    error_message = "#{status_code} error"

    # handle cases where exception occured during render
    if performed?
      self.status = status_code
      self.response_body = error_message
    else
      render status: status_code, text: error_message
    end
  end
end
