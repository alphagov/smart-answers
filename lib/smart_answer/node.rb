require "active_support/inflector"

module SmartAnswer
  class Node
    attr_accessor :flow
    attr_reader :name, :calculations

    def initialize(flow, name, &block)
      @flow = flow
      @name = name
      @on_response_blocks = []
      @calculations = []
      instance_eval(&block) if block_given?
    end

    delegate :to_sym, to: :name

    delegate :to_s, to: :name

    def filesystem_friendly_name
      to_s.sub(/\?$/, "")
    end

    def on_response(&block)
      @on_response_blocks << Block.new(&block)
    end

    def calculate(variable_name, &block)
      @calculations << Calculation.new(variable_name, &block)
    end

    def outcome?
      false
    end

    def question?
      false
    end

    def template_directory
      load_path = FlowRegistry.instance.load_path
      Pathname.new(load_path).join(String(@flow.name))
    end

    def flow_name
      @flow.name
    end
  end
end
