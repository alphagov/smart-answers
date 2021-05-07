require "active_support/inflector"

module SmartAnswer
  class Node
    attr_accessor :flow
    attr_reader :name, :view_template_path

    def initialize(flow, name, &block)
      @flow = flow
      @name = name
      @on_response_blocks = []
      instance_eval(&block) if block_given?
    end

    delegate :to_sym, to: :name

    delegate :to_s, to: :name

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

    def error(_state)
      nil
    end

    def next_node_name(state)
      next_node = state.instance_exec(&next_node_block)

      raise NextNodeUndefined, "Next node undefined." if next_node.blank?

      unless Question::NextNodeBlock.permitted?(next_node)
        raise "Next node (#{next_node}) not returned via question or outcome method"
      end

      next_node.to_sym
    end
  end
end
