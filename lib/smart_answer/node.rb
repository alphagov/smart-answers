require 'active_support/inflector'

module SmartAnswer
  class Node
    attr_reader :name
    
    def initialize(name, options = {}, &block)
      @name = name
      instance_eval(&block) if block_given?
    end

    def display_name text=nil
      return (@display_name || default_display_name) if text.nil?
      @display_name = text
    end
    
    def default_display_name
      @name.to_s.humanize
    end
    
    def to_sym
      name.to_sym
    end
    
    def to_s
      name.to_s
    end
  end
end