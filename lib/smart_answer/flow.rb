require 'ostruct'

module SmartAnswer
  class InvalidResponse < StandardError; end
  
  class Flow
    attr_reader :nodes
    attr_reader :outcomes
    attr_accessor :state
    class_attribute :load_path
    
    def initialize(&block)
      @nodes = []
      @next_question_number = 1
      @state = nil
      instance_eval(&block) if block_given?
    end
    
    def self.with_load_path(path, &block)
      old_load_path, self.load_path = self.load_path, path
      result = yield
      self.load_path = old_load_path
      result
    end
    
    def self.load(name)
      raise "Illegal flow name" unless name =~ /\A[a-zA-Z_]+\z/
      absolute_path = File.expand_path("#{name}.rb", load_path || Rails.root.join('lib', 'flows'))
      Flow.new do
        eval File.read(absolute_path)
      end
    end
    
    def display_name(text = nil)
      @display_name = text unless text.nil?
      @display_name
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
      ! node(node_or_name).nil?
    end
    
    def node(node_or_name)
      name = node_or_name.is_a?(Node) ? node_or_name.name : node_or_name.to_sym
      @nodes.find {|n| n.name == name }
    end
    
    def start_state
      OpenStruct.new(current_node: questions.first.name, responses: []).freeze
    end

    def process(responses)
      responses.inject(start_state) do |state, response|
        new_state = node(state.current_node).transition(state, response)
        validate!(new_state)
      end
    end

    def validate!(state)
      if state.current_node.nil? || ! node_exists?(state.current_node)
        raise "Flow error, can't transition to #{state.current_node}"
      end
      state
    end
    
    def path(responses)
      path, final_state = responses.inject([[], start_state]) do |memo, response|
        path, state = memo
        new_state = node(state.current_node).transition(state, response)
        validate!(new_state)
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
        if node.is_a?(Question::Base)
          node.number = @next_question_number
          @next_question_number += 1
        end
        @nodes << node
      end
  end
end