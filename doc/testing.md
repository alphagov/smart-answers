# Testing

## External dependencies

Some of the smart-answers tests require PhantomJS to be [installed on your machine
natively](https://github.com/teampoltergeist/poltergeist/blob/master/README.md#installing-phantomjs).

Smart-answers also require the govuk-content-schemas repository which can
be [cloned](https://github.com/alphagov/govuk-content-schemas) into a sibling
directory, or a directory referenced using GOVUK_CONTENT_SCHEMAS_PATH.

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

## Regression tests

See [regression tests documentation](regression-tests.md).

### Adding regression tests to Smart Answers

We're not imagining introducing new regression tests but I think [these instructions](adding-new-regression-tests.md) are still useful while we still have them in the project.
