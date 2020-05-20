module SmartAnswer
  module ErbRenderer::QuestionOptionsHelper
    def options(new_options = nil)
      @options = new_options || @options || {}
    end
  end
end
