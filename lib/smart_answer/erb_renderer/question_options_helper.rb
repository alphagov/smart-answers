module SmartAnswer
  module ErbRenderer::QuestionOptionsHelper
    def options(new_options = nil)
      @options = new_options || @options || {}
    end

    def hide_caption(hide_caption = false)
      @hide_caption = hide_caption || @hide_caption
    end

    def use_title_as_h1(use_title_as_h1 = false)
      @use_title_as_h1 = use_title_as_h1 || @use_title_as_h1
    end
  end
end
