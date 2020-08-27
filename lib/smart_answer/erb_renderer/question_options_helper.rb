module SmartAnswer
  module ErbRenderer::QuestionOptionsHelper
    def options(new_options = nil)
      @options = new_options || @options || {}
    end

    def hide_caption(hide_caption = false)
      @hide_caption = hide_caption || @hide_caption
    end
  end
end
