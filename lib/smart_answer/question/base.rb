module SmartAnswer
  module Question
    class Base < Node
      PRESENTER_CLASS = QuestionPresenter

      class NextNodeUndefined < StandardError; end

      def initialize(flow, name, &block)
        @validations = []
        @default_next_node_block = ->(_) { nil }
        @saved_input = nil
        @next_node_block = nil
        super
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

      def validate(message = nil, &block)
        @validations << [message, block]
      end

      def transition(state)
        input = parse_input(state.responses[name])
        validate!

        @on_response_blocks.each do |block|
          block.evaluate(state, input)
        end
      rescue BaseStateTransitionError => e
        GovukError.notify(e) if e.is_a?(LoggedError)
        @error = e.message
      end

      def requires_action?(state)
        state.responses[name].nil?
      end

      def parse_input(raw_input)
        raw_input
      end

      def question?
        true
      end

    private

      def next_node_block
        @next_node_block || @default_next_node_block
      end

      def validate!
        @validations.each do |message, predicate|
          unless state.instance_exec(state.responses[@name], &predicate)
            @error = message
          end
        end
      end
    end
  end
end
