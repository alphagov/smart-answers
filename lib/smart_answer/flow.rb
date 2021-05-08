require "ostruct"

module SmartAnswer
  class Flow
    attr_reader :nodes
    attr_writer :status

    def self.build
      flow = new
      flow.define
      flow
    end

    def initialize(&block)
      @nodes = []
      status(:draft)
      instance_eval(&block) if block_given?
    end

    def append(flow)
      flow.nodes.each do |node|
        node.flow = self
        add_node(node)
      end
    end

    def content_id(id = nil)
      @content_id = id unless id.nil?
      @content_id
    end

    def name(name = nil)
      @name = name unless name.nil?
      @name
    end

    def response_store(response_store = nil)
      @response_store = response_store unless response_store.nil?
      @response_store
    end

    def use_hide_this_page(use_hide_this_page)
      raise "This flow is not session based" unless response_store == :session

      @use_hide_this_page = use_hide_this_page
    end

    def use_hide_this_page?
      ActiveModel::Type::Boolean.new.cast(@use_hide_this_page)
    end

    def hide_previous_answers_on_results_page(hide_previous_answers_on_results_page) # rubocop:disable Style/TrivialAccessors
      @hide_previous_answers_on_results_page = hide_previous_answers_on_results_page
    end

    def hide_previous_answers_on_results_page?
      ActiveModel::Type::Boolean.new.cast(@hide_previous_answers_on_results_page)
    end

    def status(potential_status = nil)
      if potential_status
        raise Flow::InvalidStatus unless %i[published draft].include? potential_status

        @status = potential_status
      end

      @status
    end

    def radio(name, &block)
      add_node Question::Radio.new(self, name, &block)
    end

    def country_select(name, options = {}, &block)
      add_node Question::CountrySelect.new(self, name, options, &block)
    end

    def date_question(name, &block)
      add_node Question::Date.new(self, name, &block)
    end

    def value_question(name, options = {}, &block)
      add_node Question::Value.new(self, name, options, &block)
    end

    def money_question(name, &block)
      add_node Question::Money.new(self, name, &block)
    end

    def salary_question(name, &block)
      add_node Question::Salary.new(self, name, &block)
    end

    def checkbox_question(name, &block)
      add_node Question::Checkbox.new(self, name, &block)
    end

    def postcode_question(name, &block)
      add_node Question::Postcode.new(self, name, &block)
    end

    def outcome(name, &block)
      add_node Outcome.new(self, name, &block)
    end

    def outcomes
      @nodes.select(&:outcome?)
    end

    def questions
      @nodes.select(&:question?)
    end

    def node_exists?(name)
      @nodes.any? { |n| n.name == name }
    end

    def find_node(name)
      @nodes.find { |n| n.name == name } || raise("Node '#{name}' does not exist")
    end

    def start_node
      Node.new(self, name.underscore.to_sym)
    end

    def visited_nodes(state)
      current_node = questions.first
      nodes = [current_node]

      until current_node.nil? || state.responses[current_node.name].nil?
        current_node.transition(state)

        break if current_node.error || current_node.name == state.requested_node

        next_node_name = current_node.next_node_name(state)
        current_node = find_node(next_node_name)
        nodes << current_node
      end

      nodes
    end

    class InvalidStatus < StandardError; end

  private

    def add_node(node)
      raise "Node #{node.name} already defined" if node_exists?(node)

      @nodes << node
    end
  end
end
