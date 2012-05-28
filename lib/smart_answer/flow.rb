require 'ostruct'

module SmartAnswer
  class Flow
    attr_reader :nodes, :outcomes
    attr_accessor :state, :status, :need_id

    def initialize(&block)
      @nodes = []
      @state = nil
      instance_eval(&block) if block_given?
    end

    def name(name = nil)
      @name = name unless name.nil?
      @name
    end

    def satisfies_need(need_id)
      self.need_id = need_id
    end

    def draft?
      status == :draft
    end

    def status(s=nil)
      if s
        raise Flow::InvalidStatus unless [:published,:draft].include? s
        @status = s
      end

      @status
    end

    def section_slug(s=nil)
      @section_slug = s if s
      @section_slug
    end

    def subsection_slug(s=nil)
      @subsection_slug = s if s
      @subsection_slug
    end

    def multiple_choice(name, options = {}, &block)
      add_node Question::MultipleChoice.new(name, options, &block)
    end

    def country_select(name, options = {}, &block)
      add_node Question::CountrySelect.new(name, options, &block)
    end

    def date_question(name, &block)
      add_node Question::Date.new(name, &block)
    end

    def value_question(name, &block)
      add_node Question::Value.new(name, &block)
    end

    def money_question(name, &block)
      add_node Question::Money.new(name, &block)
    end

    def salary_question(name, &block)
      add_node Question::Salary.new(name, &block)
    end

    def outcome(name, options = {}, &block)
      add_node Outcome.new(name, options, &block)
    end

    def outcomes
      @nodes.select(&:outcome?)
    end

    def questions
      @nodes.select(&:question?)
    end

    def node_exists?(node_or_name)
      @nodes.any? {|n| n.name == node_or_name.to_sym }
    end

    def node(node_or_name)
      @nodes.find {|n| n.name == node_or_name.to_sym } or raise "Node '#{node_or_name}' does not exist"
    end

    def start_state
      State.new(questions.first.name).freeze
    end

    def process(responses)
      responses.inject(start_state) do |state, response|
        return state if state.error
        begin
          node(state.current_node).transition(state, response)
        rescue ArgumentError, InvalidResponse => e
          state.clone.tap do |new_state|
            new_state.error = e.message
            new_state.freeze
          end
        end
      end
    end

    def path(responses)
      process(responses).path
    end

    def normalize_responses(responses)
      process(responses).responses
    end

    class InvalidStatus < StandardError; end

    private
      def add_node(node)
        raise "Node #{node.name} already defined" if node_exists?(node)
        @nodes << node
      end
  end
end
