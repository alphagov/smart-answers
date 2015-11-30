# Ruby Smart Answers

## Smart answer syntax

### Storing data for later use

You can use the `precalculate`, `next_node_calculation`, `save_input_as` and `calculate` methods to store data for later use.

Use `precalculate` or `next_node_calculation` to store data for use within the same node.

Use `save_input_as` to store the answer to the question for use within subsequent nodes.

Use `calculate` to store data for use within subsequent nodes.

The flow below illustrates the data available to the different Question node methods.

    multiple_choice :question_1 do
      option :q1_option

      next_node :question_2

      calculate :q1_calculated_answer do
        'q1-calculated-answer'
      end
    end

    multiple_choice :question_2 do
      option :q2_option

      precalculate :q2_precalculated_answer do
        # responses            => ['q1_option']
        # q1_calculated_answer => 'q1-calculated-answer'

        'q2-precalculated-answer'
      end

      next_node_calculation :q2_next_node_calculated_answer do |response|
        # response                => 'q2_option'
        # responses               => ['q1_option']
        # q1_calculated_answer    => 'q1-calculated-answer'
        # q2_precalculated_answer => 'q2-precalculated-answer'

        'q2-next-node-calculated-answer'
      end

      validate do |response|
        # response                       => 'q2_option'
        # responses                      => ['q1_option']
        # q1_calculated_answer           => 'q1-calculated-answer'
        # q2_precalculated_answer        => 'q2-precalculated-answer'
        # q2_next_node_calculated_answer => 'q2-next-node-calculated-answer'
      end

      next_node do |response|
        # response                       => 'q2_option'
        # responses                      => ['q1_option']
        # q1_calculated_answer           => 'q1-calculated-answer'
        # q2_precalculated_answer        => 'q2-precalculated-answer'
        # q2_next_node_calculated_answer => 'q2-next-node-calculated-answer'
      end

      save_input_as :q2_answer

      calculate :q2_calculated_answer do |response|
        # response                       => 'q2_option'
        # responses                      => ['q1_option', 'q2_option']
        # q1_calculated_answer           => 'q1-calculated-answer'
        # q2_answer                      => 'q2_option'
        # q2_precalculated_answer        => 'q2-precalculated-answer'
        # q2_next_node_calculated_answer => 'q2-next-node-calculated-answer'
      end
    end

### Outcome templates

#### ERB

The ERB outcome templates live in `lib/smart_answer_flows/<flow-name>/<outcome-name>.govspeak.erb`.

## Testing Smart Answers

### Avoid deeply nested contexts

We previously had to use nested contexts to write integration tests around Smart Answers. This lead to deeply nested, hard to follow tests. We've removed the code that required this style and should no longer be writing these deeply nested tests.

#### Example Smart Answer Flow

    status :published

    multiple_choice :question_1 do
      option :A
      option :B

      next_node :question_2
    end

    multiple_choice :question_2 do
      option :C
      option :D

      next_node :question_3
    end

    multiple_choice :question_3 do
      option :E
      option :F

      next_node :outcome_1
    end

    outcome :outcome_1 do
    end

#### Good: Flattened test

This is how we should be writing integration tests for Smart Answer flows.

    should "exercise the example flow" do
      setup_for_testing_flow SmartAnswer::ExampleFlow

      assert_current_node :question_1
      add_response :A
      assert_current_node :question_2
      add_response :C
      assert_current_node :question_3
      add_response :E
      assert_current_node :outcome_1
    end


#### DEPRECATED: A test using nested contexts

This is how we were previously writing integration tests for Smart Answer flows.

    setup do
      setup_for_testing_flow SmartAnswer::ExampleFlow
    end

    should "be on question 1" do
      assert_current_node :question_1
    end

    context "when answering question 1" do
      setup do
        add_response :A
      end

      should "be on question 2" do
        assert_current_node :question_2
      end

      context "when answering question 2" do
        setup do
          add_response :C
        end

        should "be on question 3" do
          assert_current_node :question_3
        end

        context "when answering question 3" do
          setup do
            add_response :E
          end

          should "be on outcome 1" do
            assert_current_node :outcome_1
          end
        end
      end
    end

### Adding regression tests to Smart Answers

We're not imagining introducing new regression tests but I think [these instructions](adding-new-regression-tests.md) are still useful while we still have them in the project.
