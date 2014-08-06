module Smartdown
  class Node

    attr_reader :title

    def initialize(node)
      node_elements = node.elements.clone
      headings = node_elements.select {
          |element| element.is_a? Smartdown::Model::Element::MarkdownHeading
      }
      @title = headings.first.content if headings.first
      node_elements.delete(headings.first) #Remove page title
      @elements = node_elements
      @front_matter = node.front_matter
    end

    def has_title?
      !!title
    end

    def body
      body_elements = []
      for element in elements
        if smartdown_element?(element)
          break
        end
        body_elements << element
      end
      build_govspeak(body_elements)
    end

    def has_body?
      !!body
    end

    def has_devolved_body?
      !!devolved_body
    end

    def devolved_body
      # if no split element is found, don't do a devolved body
      element_index = -1

      elements.each_with_index { |element, index|
        if smartdown_element?(element)
          element_index = index
          break
        end
      }
      after_button_elements = elements[element_index..-1]

      build_govspeak(after_button_elements)
    end

    attr_reader :elements, :front_matter

  private

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
