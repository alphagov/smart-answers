module SmartAnswersControllerTestHelper
  def submit_response(response = nil, other_params = {})
    params = {
      id: "radio-sample",
      started: "y",
      next: "Next Question",
    }
    params[:response] = response if response
    get :show, params: params.merge(other_params)
  end

  def submit_json_response(response = nil, other_params = {})
    params = {
      id: "radio-sample",
      started: "y",
      format: "json",
      next: "1",
    }
    params[:response] = response if response
    get :show, params: params.merge(other_params)
  end

  def assert_cached_response(age: 5.minutes.to_i, public: true)
    shared_cache = public ? "public" : "private"
    assert_equal "max-age=#{age}, #{shared_cache}", @response.header["Cache-Control"]
  end

  def assert_uncached_response
    assert_equal "no-store", @response.header["Cache-Control"]
  end

  def enable_page_caching
    Rails.application.config.stubs(:set_http_cache_control_expiry_time).returns(true)
  end
end
