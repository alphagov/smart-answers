module Smartdown
  class Node

    attr_reader :title ,:elements, :front_matter

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
      elements_before_smartdown = elements.take_while{|element| !smartdown_element?(element)}
      build_govspeak(elements_before_smartdown) unless elements_before_smartdown.empty?
    end

    def has_body?
      !!body
    end

    def has_devolved_body?
      !!devolved_body
    end

    def devolved_body
      elements_after_smartdown = elements.drop_while{|element| !smartdown_element?(element)}
      build_govspeak(elements_after_smartdown)
    end

  private

    def markdown_element?(element)
      (element.is_a? Smartdown::Model::Element::MarkdownParagraph) ||
      (element.is_a? Smartdown::Model::Element::MarkdownHeading)
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
