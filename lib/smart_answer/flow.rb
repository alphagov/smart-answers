require 'ostruct'

module SmartAnswer
  class Flow
    attr_reader :nodes, :outcomes
    attr_accessor :state, :status, :need_id

    def self.build
      new.tap do |flow|
        flow.define
      end
    end

    def initialize(&block)
      @nodes = []
      @state = nil
      instance_eval(&block) if block_given?
    end

    def use_shared_logic(filename)
      eval File.read(Rails.root.join('lib', 'smart_answer_flows', 'shared_logic', "#{filename}.rb")), binding
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

    #Status for a question being transitioned from smart-answer to smartdown: do not publish
    def transition?
      status == :transition
    end

    def status(s = nil)
      if s
        raise Flow::InvalidStatus unless [:published, :draft, :transition].include? s
        @status = s
      end

      @status
    end

    def section_slug(s = nil)
      ActiveSupport::Deprecation.warn("Sections are no longer handled within smartanswers.", caller(1))
      nil
    end

    def subsection_slug(s = nil)
      ActiveSupport::Deprecation.warn("Sections are no longer handled within smartanswers.", caller(1))
      nil
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

    def value_question(name, options = {}, &block)
      add_node Question::Value.new(name, options, &block)
    end

    def money_question(name, &block)
      add_node Question::Money.new(name, &block)
    end

    def salary_question(name, &block)
      add_node Question::Salary.new(name, &block)
    end

    def checkbox_question(name, &block)
      add_node Question::Checkbox.new(name, &block)
    end

    def postcode_question(name, &block)
      add_node Question::Postcode.new(name, &block)
    end

    def outcome(name, options = {}, &block)
      modified_options = options.merge(
        flow_name: self.name
      )
      add_node Outcome.new(name, modified_options, &block)
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
          state = node(state.current_node).transition(state, response)
          node(state.current_node).evaluate_precalculations(state)
        rescue ArgumentError, InvalidResponse => e
          state.dup.tap do |new_state|
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
