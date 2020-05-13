module SmartAnswer
  module ErbRenderer::QuestionOptionsHelper
    def options(options = nil)
      if options
        @options = options
      else
        @options || {}
      end
    end
  end
end
