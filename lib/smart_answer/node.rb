require 'active_support/inflector'

module SmartAnswer
  class Node
    attr_reader :name
    
    def initialize(name, options = {}, &block)
      @name = name
      instance_eval(&block) if block_given?
    end

    def display_name text=nil
      return @display_name if text.nil?
      @display_name = text
    end
  end
end