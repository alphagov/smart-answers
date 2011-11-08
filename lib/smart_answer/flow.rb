require 'ostruct'

module SmartAnswer
  class InvalidResponse < StandardError; end
  
  class Flow
    attr_reader :nodes
    attr_reader :outcomes
    attr_accessor :state
    
    def initialize(&block)
      @nodes = []
      @state = nil
      instance_eval(&block) if block_given?
    end
    
    def name(name = nil)
      @name = name unless name.nil?
      @name
    end
    
    def multiple_choice(name, options = {}, &block)
      add_node Question::MultipleChoice.new(name, options, &block)
    end

    def date_question(name, &block)
      add_node Question::Date.new(name, &block)
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

    def node_exists?(node_or_name)
      @nodes.any? {|n| n.name == node_or_name.to_sym }
    end
    
    def node(node_or_name)
      @nodes.find {|n| n.name == node_or_name.to_sym } or raise "Node #{name} does not exist"
    end
    
    def start_state
      State.new(questions.first.name).freeze
    end

    def process(responses)
      responses.inject(start_state) do |state, response|
        node(state.current_node).transition(state, response)
      end
    end

    def path(responses)
      path, final_state = responses.inject([[], start_state]) do |memo, response|
        path, state = memo
        new_state = node(state.current_node).transition(state, response)
        [path + [state.current_node], new_state]
      end
      path
    end
    
    def normalize_responses(responses)
      process(responses).responses
    end
    
    private
      def add_node(node)
        raise "Node #{node.name} already defined" if node_exists?(node)
        @nodes << node
      end
  end
end