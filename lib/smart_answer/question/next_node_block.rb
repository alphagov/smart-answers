require 'method_source'

module SmartAnswer
  module Question
    module NextNodeBlock
      class PermittedNodeKey < SimpleDelegator
        delegate :nil?, to: :__getobj__
      end

      def self.permitted?(node)
        PermittedNodeKey === node
      end

      module InstanceMethods
        def question(key)
          PermittedNodeKey.new(key)
        end

        def outcome(key)
          PermittedNodeKey.new(key)
        end

        def self.methods_of_interest
          instance_methods(false).map { |name| instance_method(name) }
        end
      end

      class Parser
        def initialize
          @parser = MethodInvocationsParser.new(
            *InstanceMethods.methods_of_interest
          )
        end

        def possible_next_nodes(next_node_block)
          @parser.invocations(next_node_block.source)
            .map { |invocation| invocation[:arg_nodes][0] }
            .select { |node| node.type == :sym }
            .map { |node| node.children[0] }
        end
      end
    end
  end
end
