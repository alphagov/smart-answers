# Ruby Smart Answers

## File structure

This is an overview of the components that make up a single Smart Answer.

* lib/
  * smart_answer/
    * calculators/
      * _calculator-name_.rb (__Optional: Object encapsulating business logic for the flow__)
  * smart_answer_flows/
    * locales/
      * en/
        * _flow-name_.yml (__Optional: Data used to build questions e.g. question and option text__)
    * _flow-name_.rb (__Required: Flow and question logic__)
    * _flow-name_/
      * _flow-name_.govspeak.erb (__Optional: Content for the landing page__)
      * _outcome-name_.govspeak.erb (__Optional: Content for each outcome page__)
      * __partial-name_.govspeak.erb (__Optional: Useful when you need to share content between outcome templates__)
    * shared/
      * _shared-directory-name_/
        * __partial-name_.govspeak.erb (__Optional: Useful when you need to share content between Smart Answers__)
    * shared_logic/
      * _shared-logic-name_.rb (__Optional: Useful when you need to share flow and question logic between Smart Answers__)

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

### Question types

* `checkbox_question` - choose multiple values from a list of values. Response is a list.
* `country_select` - choose a single country.
* `date_question` - choose a single date
* `money_question` - enter a money amount. The response is converted to a `Money` object.
* `multiple_choice` - choose a single value from a list of values. Response is a string.
* `postcode_question` - enter a postcode. Response is checked for validity and returned as a normalised string.
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

##### Predicate helpers

* `responded_with(value)` - `value` can be either a string or an array of values
* `variable_matches(varname, value)` - `varname` is a symbol representing the name of the variable to test, `value` can be either a single value or an array
* `response_has_all_of(required_responses)` - only for checkbox questions, true if all of the required responses were checked. `required_responses` can be a single value or an array.
* `response_is_one_of(responses)` -  only for checkbox questions, true if ANY of the responses were checked. `responses` can be a single value or an array.

##### Combining predicates

Predicates can be combined using logical conjunctions `|` or `&`:

```ruby
next_node_if(:orange, variable_matches(:first_colour, "red") & variable_matches(:second_colour, "yellow"))
next_node_if(:monochrome, variable_matches(:first_colour, "black") | variable_matches(:second_colour, "white"))
```

##### Structuring rules by nesting

Predicates can also be organised by nesting using `on_condition`, e.g.

```ruby
on_condition(responded_with("red")) do
  next_node_if(:orange, variable_matches(:first_color, "yellow"))
  next_node(:red)
end
next_node(:blue)
```

Here's a truth table for the above scenario:

```
|       | Yellow | other
| Red   | orange | red
| other | blue   | blue
```

##### Defining named predicates

Named predicates can also be defined using

```ruby
define_predicate(:can_has_cheesburger?) do |response|
  # logic here…
end

next_node_if(:something, can_has_cheesburger?)
```

#### DEPRECATED: Using Multiple Choice shortcut

Again using the original example:

```ruby
multiple_choice :question do
  option green: :green
  option red: :red
end
```

This is essentially some syntactic sugar on top of the predicate logic.

### Outcome templates

#### ERB

The ERB outcome templates live in `lib/smart_answer_flows/<flow-name>/<outcome-name>.govspeak.erb`.

##### Indentation

Since all the content in the ERB templates is within one or other `content_for` blocks, we've chosen not to indent the outer level of ERB tags within the blocks.

Content within ERB tags should be indented at the appropriate level - leading spaces are stripped before the content is processed by Govspeak.

###### Correct indentation example

    <% content_for :body do %>
    <% if foo %>
      Foo text
      <% if bar %>
        Bar text
      <% end %>
    <% end %>
    <% end %>

###### Incorrect indentation example

    <% content_for :body do %>
      <% if foo %>
    Foo text
        <% if bar %>
    Bar text
        <% end %>
      <% end %>
    <% end %>

## Testing Smart Answers

You used to need to use nested contexts/tests in order to test Ruby/YAML Smart Answers. This is no longer needed, feel free to flatten tests that are too deeply nested.

### Example Smart Answer Flow

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

### A test using nested contexts

This test passes using the example flow above.

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

### Flattened test

The same test as above in a flattened form. It passes using the example flow above.

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
