require "slimmer/headers"

class ApplicationController < ActionController::Base
  include Slimmer::Headers
  before_filter :set_analytics_headers

protected
  def set_analytics_headers
    set_slimmer_headers(
      format:      "smart_answers"
    )
  end
end
