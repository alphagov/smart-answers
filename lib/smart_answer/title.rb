module SmartAnswer
  class Title
    def initialize(content)
      @content = content
    end

    def wrapped_with_debug_div?
      @content.match(/^<div data-debug-template-path=.*><p>.*<\/p><\/div>$/i)
    end

    def text
      return @content unless wrapped_with_debug_div?

      document_fragment.children.first.children.first.children.text
    end

    def partial_template_path
      return unless wrapped_with_debug_div?

      document_fragment.children.first.attributes.first.last.value
    end

  private

    def document_fragment
      @document_fragment ||= Nokogiri::HTML::DocumentFragment.parse(@content)
    end
  end
end
