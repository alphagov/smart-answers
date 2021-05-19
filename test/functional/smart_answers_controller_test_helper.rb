module SmartAnswersControllerTestHelper
  def submit_response(response = nil, other_params = {})
    params = {
      id: "smart-answers-controller-sample",
      started: "y",
      next: "Next Question",
    }
    params[:response] = response if response
    get :show, params: params.merge(other_params)
  end

  def submit_json_response(response = nil, other_params = {})
    params = {
      id: "smart-answers-controller-sample",
      started: "y",
      format: "json",
      next: "1",
    }
    params[:response] = response if response
    get :show, params: params.merge(other_params)
  end
end
