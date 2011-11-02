class SmartAnswersController < ApplicationController
  before_filter :find_smart_answer
  before_filter :redirect_response_to_canonical_url
  rescue_from SmartAnswer::FlowRegistry::NotFound, with: :render_404

  def show
    respond_to do |format|
      format.html { render }
      format.json { 
        render :json => {
          url: smart_answer_path(params[:id], 'y', @presenter.responses),
          html_fragment: with_format('html') {
            render_to_string(partial: "content")
          }
        }
      }
    end
  end
  
  private
  
    def with_format(format, &block)
      old_formats = self.formats
      self.formats = [format]
      result = yield
      self.formats = old_formats
      result
    end
    
    def find_smart_answer
      @name = params[:id].to_sym
      smart_answer = SmartAnswer::FlowRegistry.find(@name.to_s)
      @presenter = SmartAnswerPresenter.new(params, smart_answer)
    end
    
    def redirect_response_to_canonical_url
      if params[:response]
        responses = @presenter.responses.dup
        responses << params[:response]
        redirect_to action: :show, id: @name, 
          started: 'y', 
          responses: @presenter.flow.normalize_responses(responses)
      end
    end
    
    def render_404
      render file: 'public/404.html', status: 404
    end
end
