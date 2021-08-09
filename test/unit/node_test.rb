require_relative "../test_helper"

module SmartAnswer
  class NodeTest < ActiveSupport::TestCase
    setup do
      @flow = Flow.build
      @node = Node.new(@flow, "node-name")
      @load_path = FlowRegistry.instance.load_path
    end

    test "#template_directory returns the path to the templates based on the class name" do
      @flow.class.stubs(:name).returns("MyFlow")

      expected_directory = Pathname.new(@load_path).join("my_flow")
      assert_equal expected_directory, @node.template_directory
    end

    test "#template_name can set a specific template name" do
      question = Question::Base.new(@flow, :how_much?)
      question.template_name("custom_template_file")
      assert_equal "custom_template_file", question.template_name
    end

    test "#template_name defaults to returning the filesystem_friendly_name" do
      question = Question::Base.new(@flow, :how_much?)
      assert_equal question.filesystem_friendly_name, question.template_name
    end

    test "#filesystem_friendly_name returns name without trailing question mark" do
      question = Question::Base.new(@flow, :how_much?)
      assert_equal "how_much", question.filesystem_friendly_name
    end

    test "#slug returns name without trailing question mark and underscores replaced with dashes" do
      question = Question::Base.new(@flow, :how_much?)
      assert_equal "how-much", question.slug
    end

    test "#view_template sets the view template path" do
      node = Node.new(@flow, "node-name") { view_template "path/to/view" }
      assert_equal "path/to/view", node.view_template_path
    end

    test "#view_template_path return nil is not set" do
      node = Node.new(@flow, "node-name")
      assert_nil node.view_template_path
    end

    test "#presenter returns a presenter object" do
      node = Node.new(@flow, "node-name")
      assert_instance_of Node::PRESENTER_CLASS, node.presenter
    end

    context "#next_node" do
      should "raise exception if next_node is called without a block" do
        e = assert_raises(ArgumentError) do
          @node.next_node
        end
        assert_equal "You must specify a block", e.message
      end

      should "raise exception if next_node is invoked multiple times" do
        e = assert_raises do
          @node.next_node { outcome :one }
          @node.next_node { outcome :two }
        end
        assert_equal "Multiple calls to next_node are not allowed", e.message
      end
    end

    context "#permitted_next_nodes" do
      should "return nodes returned via syntactic sugar methods" do
        @node.next_node do |response|
          if response == "yes"
            outcome :done
          else
            question :another_question
          end
        end
        assert_equal %i[done another_question], @node.permitted_next_nodes
      end

      should "not return nodes not returned via syntactic sugar methods" do
        @node.next_node do |response|
          if response == "yes"
            outcome :done
          else
            :another_question
          end
        end
        assert @node.permitted_next_nodes.include?(:done)
        assert_not @node.permitted_next_nodes.include?(:another_question)
      end

      should "not return duplicate permitted next nodes" do
        @node.next_node { outcome :done }
        assert_equal [:done], @node.permitted_next_nodes
      end
    end

    context "#setup" do
      should "be a method" do
        assert_equal nil, @node.setup(nil)
      end
    end

    context "#transition" do
      should "copy values from initial state to new state" do
        @node.next_node { outcome :done }
        initial_state = SmartAnswer::State.new(@node.name)
        initial_state.something_else = "Carried over"
        new_state = @node.transition(initial_state, nil)
        assert_equal "Carried over", new_state.something_else
      end

      should "set current_node_name to value returned from next_node_for" do
        @node.next_node { outcome :done }
        initial_state = SmartAnswer::State.new(@node.name)
        @node.stubs(:next_node_for).returns(:done)
        new_state = @node.transition(initial_state, nil)
        assert_equal :done, new_state.current_node_name
      end

      should "set current_node_name to result of calling next_node block" do
        @node.next_node { outcome :done }
        initial_state = SmartAnswer::State.new(@node.name)
        new_state = @node.transition(initial_state, nil)
        assert_equal :done, new_state.current_node_name
      end

      should "make state available to code in next_node block" do
        @node.next_node do
          colour == "red" ? outcome(:was_red) : outcome(:wasnt_red)
        end
        initial_state = SmartAnswer::State.new(@node.name)
        initial_state.colour = "red"
        new_state = @node.transition(initial_state, nil)
        assert_equal :was_red, new_state.current_node_name
      end
    end

    context "#next_node_for" do
      should "raise an exception if next_node does not return key via question or outcome method" do
        @node.next_node do
          outcome :another_outcome
          :not_allowed_next_node
        end
        state = SmartAnswer::State.new(@node.name)

        expected_message = "Next node (not_allowed_next_node) not returned via question or outcome method"
        exception = assert_raises do
          @node.next_node_for(state, "response")
        end
        assert_equal expected_message, exception.message
      end

      should "raise an exception if next_node does not return a node key" do
        @node.next_node do
          skip = false
          outcome :skipped if skip
        end
        initial_state = SmartAnswer::State.new(@node.name)
        initial_state.accepted_responses = { question_1: "red" }
        error = assert_raises(SmartAnswer::Node::NextNodeUndefined) do
          @node.next_node_for(initial_state, nil)
        end
        expected_message = %(Next node undefined. Node: #{@node.name}.)
        assert_equal expected_message, error.message
      end

      should "raise an exception if next_node was not called for question" do
        initial_state = SmartAnswer::State.new(@node.name)
        assert_raises(SmartAnswer::Node::NextNodeUndefined) do
          @node.next_node_for(initial_state, nil)
        end
      end

      should "allow calls to #question syntactic sugar method" do
        @node.next_node { question :another_question }
        state = SmartAnswer::State.new(@node.name)
        next_node = @node.next_node_for(state, nil)
        assert_equal :another_question, next_node
      end

      should "should allow calls to #outcome syntactic sugar method" do
        @node.next_node { outcome :done }
        state = SmartAnswer::State.new(@node.name)
        next_node = @node.next_node_for(state, nil)
        assert_equal :done, next_node
      end
    end
  end
end
