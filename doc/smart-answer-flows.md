# Ruby Smart Answers

## File structure

This is an overview of the components that make up a single Smart Answer.

```
lib
|__ smart_answer
|   |__ calculators
|       |__ <calculator-name>.rb (Optional: Object encapsulating business logic for the flow)
|__ smart_answer_flows
    |__ locales
    |   |__ en
    |       |__ <flow-name>.yml (Optional: Data used to build questions e.g. question and option text)
    |__ <flow-name>.rb (Required: Flow and question logic)
    |__ <flow-name>
    |   |__ <flow-name>.govspeak.erb (Optional: Content for the landing page)
    |   |__ <outcome-name>.govspeak.erb (Optional: Content for each outcome page)
    |   |__ _<partial-name>.govspeak.erb (Optional: Useful when you need to share content between outcome templates)
    |__ shared
    |    |__ <shared-directory-name>
    |        |__ _<partial-name>.govspeak.erb (Optional: Useful when you need to share content between Smart Answers)
    |__ shared_logic
        |__ <shared-logic-name>.rb (Optional: Useful when you need to share flow and question logic between Smart Answers)
```

## Smart answer syntax

### Question types

* `checkbox_question` - choose multiple values from a list of values. Response is a list.
* `country_select` - choose a single country.
* `date_question` - choose a single date
* `money_question` - enter a money amount. The response is converted to a `Money` object.
* `multiple_choice` - choose a single value from a list of values. Response is a string.
* `postcode_question` - enter a postcode. Response is checked for validity and returned as a string containing a normalised postcode (e.g. "wc2b6nh" becomes "WC2B 6NH").
* `salary_question` - enter a salary as either a weekly or monthly money amount. Coverted to a `Salary` object.
* `value_question` - enter a single string value (free text)

### Defining next node rules

There are three syntaxes for defining next node rules.

#### Using `next_node` with a block

This is the preferred syntax. A current disadvantage is that these flows can't be visualised, although we're planning to fix that.

```ruby
next_node do |response|
  if response == 'green'
    :green # Go to the :green node
  else
    :red   # Go to the :red node
  end
end
```

#### DEPRECATED: Using predicates

This is the same example from above expressed using predicates:

```ruby
next_node_if(:green, responded_with('green')) )
next_node(:red)
```

The `responded_with` function actually returns a [predicate](http://en.wikipedia.org/wiki/Predicate_%28mathematical_logic%29) which will be invoked during processing. If the predicate returns `true` then the `:green` node will be next, otherwise the next rule will be evaluated. In this case the next rule says `:red` is the next node with no condition.

See [Smart Answer predicates](./smart-answers-predicates.md) for more detailed information about this style.

#### DEPRECATED: Using Multiple Choice shortcut

Again using the original example:

```ruby
multiple_choice :question do
  option green: :green
  option red: :red
end
```

This is essentially some syntactic sugar on top of the predicate logic.

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

      define_predicate :q2_named_predicate do |response|
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

We're not imagining introducing new regression tests but I think these instructions are still useful while we still have them in the project.

1. Update the flow to replace any single line conditionals around `Phraselist`s with multiple line conditionals. This is so that we get useful information from the running the coverage utility. Single line conditionals will show up as having been exercised irrespective of whether they caused something to be added to the `Phraselist`.

        # Replace single line conditional
        phrases << :new_phrase if condition

        # With multiple line alternative
        if condition
          phrases << :new_phrase
        end

2. Generate a set of responses for the flow that you want to add regression tests to.

        $ rails r script/generate-questions-and-responses-for-smart-answer.rb \
          <name-of-smart-answer>

3. Commit the generated questions-and-responses.yml file (in test/data) to git.

4. Change the file by adding/removing and changing the responses:

  * Add responses for any of the TODO items in the file.

  * Remove responses that you don't think cause the code to follow different branches, e.g. it might be useful to remove all but one (or a small number) of countries to avoid a combinatorial explosion of input responses.

  * Combine responses for checkbox questions where the effect of combining them doesn't affect the number of branches of the code that are exercised.

5. Commit the updated questions-and-responses.yml file to git.

6. Generate a set of input responses and expected results for the Smart Answer.

        $ rm -rf coverage && \
          TEST_COVERAGE=true \
          rails r script/generate-responses-and-expected-results-for-smart-answer.rb \
          <name-of-smart-answer>

7. Inspect the code coverage report for the Smart Answer under test (`open coverage/rcov/index.html` and find the smart answer under test).

  * If all the branches in the flow have been exercised then you don't need to do anything else at this time.

      * Code in node-level blocks (e.g. in `value_question`, `date_question`, `multiple_choice` & `outcome` blocks) will always be executed at *flow-definition-time*, and so coverage of these lines is of **no** significance when assessing test coverage of the flow logic.

      * Code in blocks inside node-level blocks (e.g. in `precalculate`, `next_node_calculation`, `validate` & `define_predicate` blocks) will be executed at *flow-execution-time*, and so coverage of these lines is of significance when assessing test coverage of the flow logic.

      * Coverage of code in ancillary classes (e.g. calculators) should also be considered at this point.

  * If there are branches in the flow that haven't been exercised then:

      * Determine the responses required to exercise those branches.

      * Go to Step 4, add the new responses and continue through the steps up to Step 7.

8. Commit the generated responses-and-expected-results.yml file (in test/data) to git.

9. Generate a yaml file containing the set of source files that this Smart Answer depends upon. The script will automatically take the ruby flow file, locale file and erb templates into account. You just need to supply it with the location of any additional files required by the Smart Answer (e.g. calculators and data files). This data is used to determine whether to run the regression tests based on whether the source files have changed.

        $ rails r script/generate-checksums-for-smart-answer.rb \
          <name-of-smart-answer> \
          <path/to/additional/files>

10. Commit the generated yaml file to git.

11. Run the regression test to generate the Govspeak of each landing page and outcome reached by the set of input responses.

        $ RUN_REGRESSION_TESTS=<name-of-smart-answer> \
          ruby test/regression/smart_answers_regression_test.rb

If you want individual tests to fail early when differences are detected, set `ASSERT_EACH_ARTEFACT=true`.
Note that this more than doubles the time it takes to run regression tests.

12. Commit the generated Govspeak files (in test/artefacts) to git.
