require "active_support/inflector"

module SmartAnswer
  class Node
    PRESENTER_CLASS = NodePresenter

    class NextNodeUndefined < StandardError; end

    attr_accessor :flow
    attr_reader :name, :view_template_path

    def initialize(flow, name, &block)
      @flow = flow
      @name = name
      @template_name = filesystem_friendly_name

      @default_next_node_block = ->(_) { nil }
      @next_node_block = nil

      instance_eval(&block) if block_given?
    end

    delegate :to_sym, to: :name

    delegate :to_s, to: :name

    def template_name(template_name = nil)
      @template_name = template_name unless template_name.nil?
      @template_name
    end

    def presenter(flow_presenter: nil, state: nil)
      self.class::PRESENTER_CLASS.new(self, flow_presenter, state)
    end

    def filesystem_friendly_name
      to_s.sub(/\?$/, "")
    end

    def slug
      filesystem_friendly_name.dasherize
    end

    def outcome?
      false
    end

    def question?
      false
    end

    def template_directory
      load_path = FlowRegistry.instance.load_path
      Pathname.new(load_path).join(@flow.class.name.underscore)
    end

    def view_template(path)
      @view_template_path = path
    end

    def next_node(&block)
      unless block_given?
        raise ArgumentError, "You must specify a block"
      end
      if @next_node_block.present?
        raise "Multiple calls to next_node are not allowed"
      end

      @next_node_block = block
    end

    def permitted_next_nodes
      @permitted_next_nodes ||= begin
        parser = NextNodeBlock::Parser.new
        parser.possible_next_nodes(@next_node_block).uniq
      end
    end

    def setup(_state); end

    def transition(current_state, _input)
      new_state = current_state.dup
      next_node = next_node_for(new_state, nil)
      new_state.transition_to(next_node, nil)
    end

    def next_node_for(current_state, input)
      state = current_state.dup.extend(NextNodeBlock::InstanceMethods).freeze
      next_node = state.instance_exec(input, &next_node_block)
      if next_node.blank?
        message = "Next node undefined. Node: #{current_state.current_node_name}."
        raise NextNodeUndefined, message
      end
      unless NextNodeBlock.permitted?(next_node)
        raise "Next node (#{next_node}) not returned via question or outcome method"
      end

      next_node.to_sym
    end

    def redact(filter = false) # rubocop:disable Style/OptionalBooleanParameter
      @redact ||= filter
    end

  private

    def next_node_block
      @next_node_block || @default_next_node_block
    end
  end
end
