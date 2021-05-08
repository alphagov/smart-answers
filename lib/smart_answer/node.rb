require "active_support/inflector"

module SmartAnswer
  class Node
    PRESENTER_CLASS = NodePresenter
    attr_accessor :flow
    attr_reader :name, :view_template_path, :error

    def initialize(flow, name, &block)
      @flow = flow
      @name = name.to_s
      @error = nil
      @on_response_blocks = []
      instance_eval(&block) if block_given?
    end

    delegate :to_sym, to: :name

    delegate :to_s, to: :name

    def presenter(state)
      self.class::PRESENTER_CLASS.new(self, state, {})
    end

    def filesystem_friendly_name
      to_s.sub(/\?$/, "")
    end

    def slug
      filesystem_friendly_name.dasherize
    end

    def on_response(&block)
      @on_response_blocks << Block.new(&block)
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

    def view_template(path)
      @view_template_path = path
    end

    def transition(_state); end

    def next_node_name(state)
      response = state.responses[name]
      next_node = state.instance_exec(response, &next_node_block)

      next_node.to_s
    end
  end
end
