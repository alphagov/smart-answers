# Ruby Smart Answers

## File structure

This is an overview of the components that make up a single Smart Answer.

```
lib
|__ smart_answer
|   |__ calculators
|       |__ <calculator-name>.rb (Optional: Object encapsulating business logic for the flow)
|__ smart_answer_flows
    |__ <flow-name>.rb (Required: Flow and question logic)
    |__ <flow-name>
    |   |__ <flow-name>.govspeak.erb (Optional: Content for the landing page)
    |   |__ outcomes
    |   |   |__ <outcome-name>.govspeak.erb (Optional: Content for each outcome page)
    |   |   |__ _<partial-name>.govspeak.erb (Optional: Useful when you need to share content between outcome templates)
    |   |__ questions
    |   |   |__ <question-name>.govspeak.erb (Optional: Data used to build questions e.g. question and option text)
    |__ shared
    |    |__ <shared-directory-name>
    |        |__ _<partial-name>.govspeak.erb (Optional: Useful when you need to share content between Smart Answers)
    |__ shared_logic
        |__ <shared-logic-name>.rb (Optional: Useful when you need to share flow and question logic between Smart Answers)
```

## Smart answer syntax

### The flow

The Ruby flow file defines a `Flow` class that contains all the questions, outcomes and rules to control flow between.

The file should be named the same as the path that we want the Smart Answer to be accessible at on gov.uk. For example, if we want the Smart Answer to be accessible at www.gov.uk/example-smart-answer then:

* The flow file should be 'example-smart-answer.rb'
* The flow class should be `ExampleSmartAnswerFlow`
* The flow name should be 'example-smart-answer'

The `Flow` class contains a single `#define` method that defines the questions (see "Question types" below), rules (see "Defining next node rules" below) and outcomes (see "Outcome templates" below).

### Question types

* `checkbox_question`
  * User input: Choose zero to many options from a list of options.
  * Validation: Must be in the list of options.
  * Response: String containing comma-separated list of chosen options.

* `country_select`
  * Options:
    * `exclude_countries`: Optional. Array of countries to exclude from the list.
    * `include_uk`: Optional. Boolean indicating whether to include 'united-kingdom' in the list.
    * `additional_countries`: Optional. Array of countries to add to the list.
  * User input: Choose a single country.
  * Validation: Must be in the list of countries.
  * Response: String containing the chosen country.

* `date_question`
  * User input: Choose a single date.
  * Validation: Must be a valid date.
  * Response: `Date` object.

* `money_question`
  * User input: Enter a money amount.
  * Validation: Must be a number.
  * Response: `Money` object.

* `multiple_choice`
  * User input: Choose a single option from a list of options.
  * Validation: Must be in the list of options.
  * Response: String containing the chosen option.

* `postcode_question`
  * User input: Enter a postcode.
  * Validation: Must be a valid postcode.
  * Response: String containing a normalised postcode (e.g. "wc2b6nh" becomes "WC2B 6NH").

* `salary_question`
  * User input: Enter an Amount and associated Period.
  * Validation: Amount must be a valid `Money` object and Period must be one of 'year', 'month' or 'week'.
  * Response: `Salary` object.

* `value_question`
  * Options:
    * `parse`: Optional. One of `Integer`, `:to_i`, `Float` or `:to_f`
  * User input: Enter any text.
  * Validation (depends on the `parse` option):
    * `Integer`: Must be a number.
    * `:to_i`: Should be a number but non numbers are valid.
    * `Float`: Must be a number.
    * `:to_f`: Should be a number but non numbers are valid.
    * `<anything-else>`: No validation.
  * Response (depends on the `parse` option):
    * `Integer`: Integer.
    * `:to_i`: Integer (Non-numeric input returns 0).
    * `Float`: Float.
    * `:to_f`: Float (Non-numeric input returns 0.0).
    * `<anything-else>`: String containing the user input.

### Defining next node rules

#### Using `next_node` with a block

We define the permitted next nodes so that we can visualise the Smart Answer flows.

```ruby
permitted_next_nodes = [
  :green,
  :red
]
next_node(permitted: permitted_next_nodes) do |response|
  if response == 'green'
    :green # Go to the :green node
  else
    :red   # Go to the :red node
  end
end
```

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
