class SmartAnswersController < ApplicationController
  before_filter :find_smart_answer
  before_filter :redirect_response_to_canonical_url

  private
    def smart_answer(label)
      case label
      when :maternity
        MaternityAnswer.new
      when :sweet_tooth
        SweetToothAnswer.new
      else
        raise ActionController::RoutingError, 'Not Found', caller
      end
    end
    
    def find_smart_answer
      @name = params[:id].to_sym
      @presenter = SmartAnswerPresenter.new(params, smart_answer(@name))
    end
    
    def redirect_response_to_canonical_url
      if params[:response]
        responses = @presenter.responses + [params[:response]]
        redirect_to action: :show, id: @name, started: 'y', responses: responses
      end
    end
end
