require 'smartdown'
require 'smartdown/engine'

  class Flow

    def initialize(name)
      @name = name
      coversheet_path = Rails.root.join('lib', 'smartdown_flows', @name, "#{name}.txt")
      input = Smartdown::Parser::DirectoryInput.new(coversheet_path)
      @smartdown_flow = Smartdown::Parser::FlowInterpreter.new(input).interpret
      @engine = Smartdown::Engine.new(@smartdown_flow)
    end

    def inspect
      "#<SmartdownTransform::Flow(name: '#{@name}')>"
    end

    def state(started, responses)
      #TODO: we are explicitly promoting parts of Smartdown state, we will add new ones as they are needed
      state = smartdown_state(started, responses)
      State.new(node_by_name(state.get(:current_node)),
                previous_question_nodes_for(state),
                responses
      )
    end

    def title
      coversheet.title
    end

    def meta_description
      front_matter.meta_description
    end

    def need_id
      front_matter.satisfies_need
    end

    def status
      front_matter.status
    end

    def draft?
      status == 'draft'
    end

    def transition?
      status == 'transition'
    end

    def published?
      status == 'published'
    end

  private

    def coversheet
      @coversheet ||= Coversheet.new(@smartdown_flow.coversheet)
    end

    def front_matter
      @front_matter ||= coversheet.front_matter
    end

    def smartdown_state(started, responses)
      smartdown_responses = responses.clone
      if started
        smartdown_responses.unshift('y')
      end
      @engine.process(smartdown_responses)
    end

    def node_by_name(node_name)
      @smartdown_flow.node(node_name)
    end

    def previous_question_nodes_for(state)
      node_path = state.get('path')
      return [] if node_path.empty?

      node_path[1..-1].map do |node_name|
        node_by_name(node_name)
      end
    end

  end
end
