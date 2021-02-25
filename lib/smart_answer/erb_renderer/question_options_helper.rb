module SmartAnswer
  module ErbRenderer::QuestionOptionsHelper
    def options(new_options = nil)
      @options = new_options || @options || {}
    end

    def hide_caption(hide_caption = false) # rubocop:disable Style/OptionalBooleanParameter
      @hide_caption = hide_caption || @hide_caption
    end

    def use_title_as_h1(use_title_as_h1 = false) # rubocop:disable Style/OptionalBooleanParameter
      @use_title_as_h1 = use_title_as_h1 || @use_title_as_h1
    end
  end
end
