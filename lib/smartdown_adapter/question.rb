module SmartdownAdapter
  class Question

    attr_reader :number

    def initialize(elements, number=nil)
      @elements = elements
      @number = number
    end

    def title
      elements.first.content
    end

    def has_body?
      !!body
    end

    def body
      elements_before_smartdown = elements[1..-1].take_while{|element| !smartdown_element?(element)}
      build_govspeak(elements_before_smartdown)
    end

    def has_hint?
      !!hint
    end

    # Usage TBC, most hints should actually be `body`s, semi-deprecated
    # As we transition content we should better define it, or remove it
    def hint
    end

    def prefix
      "prefix not currently possible"
    end

    def suffix
      "suffix not currently possible"
    end

    def subtitle
      "subtitle not currently possible"
    end

    #TODO: when error handling
    def error
    end

    #TODO
    def responses
    end

  private

    attr_reader :elements

    def markdown_element?(element)
      (element.is_a? Smartdown::Model::Element::MarkdownParagraph) || (element.is_a? Smartdown::Model::Element::MarkdownHeading)
    end

    def smartdown_element?(element)
      !markdown_element?(element)
    end

    def build_govspeak(elements)
      markdown_elements = elements.select do |element|
        markdown_element?(element)
      end
      GovspeakPresenter.new(markdown_elements.map(&:content).join("\n")).html
    end
  end
end
