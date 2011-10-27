require 'ostruct'

module SmartAnswer
  class Flow
    attr_reader :nodes
    attr_reader :outcomes
    attr_accessor :state
    
    def initialize(&block)
      @nodes = []
      @state = nil
      instance_eval(&block) if block_given?
    end
    
    def display_name(text = nil)
      @display_name = text unless text.nil?
      @display_name
    end
    
    def multiple_choice(name, options = {}, &block)
      add_node Question::MultipleChoice.new(name, options, &block)
    end
    
    def outcome(name, options = {}, &block)
      add_node Outcome.new(name, options, &block)
    end
    
    def outcomes
      @nodes.select { |n| n.is_a?(Outcome) }
    end

    def questions
      @nodes.select { |n| n.is_a?(Question::Base) }
    end

    def start!
      @state = OpenStruct.new(current_node: questions.first.name).freeze
    end

    def node_exists?(node_or_name)
      name = node_or_name.is_a?(Node) ? node_or_name.name : node_or_name.to_sym
      @nodes.any? {|n| n.name == name }
    end
    
    private
      def add_node(node)
        raise "Node #{node.name} already defined" if node_exists?(node)
        @nodes << node
      end
  end
end