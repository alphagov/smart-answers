module SmartAnswersControllerTestHelper
  def submit_response(response = nil, other_params = {})
    params = {
      id: 'smart-answers-controller-sample',
      started: 'y',
      next: "Next Question"
    }
    params[:response] = response if response
    get :show, params.merge(other_params)
  end

  def submit_json_response(response = nil, other_params = {})
    params = {
      id: 'smart-answers-controller-sample',
      started: 'y',
      format: "json",
      next: "1"
    }
    params[:response] = response if response
    get :show, params.merge(other_params)
  end

  def with_cache_control_expiry(&block)
    original_value = Rails.configuration.set_http_cache_control_expiry_time
    Rails.configuration.set_http_cache_control_expiry_time = true
    block.call
    Rails.configuration.set_http_cache_control_expiry_time = original_value
  end
end
