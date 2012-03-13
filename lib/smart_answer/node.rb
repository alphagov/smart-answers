require 'active_support/inflector'

module SmartAnswer
  class Node
    attr_reader :name

    def initialize(name, options = {}, &block)
      @name = name
      instance_eval(&block) if block_given?
    end

    def to_sym
      name.to_sym
    end

    def to_s
      name.to_s
    end

    def outcome?
      false
    end

    def question?
      false
    end
  end
end
