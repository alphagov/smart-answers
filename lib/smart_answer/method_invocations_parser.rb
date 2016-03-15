require 'parser/current'

module SmartAnswer
  class MethodInvocationsParser
    class Processor < Parser::AST::Processor
      attr_reader :invocations

      def initialize(methods)
        @methods = methods
        @invocations = []
      end

      def on_send(node)
        _receiver_node, method_name, *arg_nodes = *node
        method = matching_method(method_name, arg_nodes.length)
        if method.present?
          @invocations << { method: method, arg_nodes: arg_nodes }
        end
        super(node)
      end

    private

      def matching_method(method_name, arity)
        @methods.detect { |m| m.name == method_name && m.arity == arity }
      end
    end

    def initialize(*methods_of_interest)
      @processor = Processor.new(methods_of_interest)
    end

    def invocations(source)
      ast = Parser::CurrentRuby.parse(source)
      @processor.process(ast)
      @processor.invocations
    end
  end
end
