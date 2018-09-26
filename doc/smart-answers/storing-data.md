# Storing data for later use

You can use the `on_response`, `precalculate`, `save_input_as` and `calculate` methods to store data for later use. These values are stored in the state and are available in the rest of the flow and in the ERB templates.

* `precalculate` values are available in:
  * The question template
  * The `validate` block
  * The `next_node` block
  * The `calculate` block
  * All subsequent questions and outcomes

__NOTE.__ `precalculate` blocks are not evaluated in the first question. This is because they're evaluated during the transition of one question to the next.

* `on_response` values are available in:
  * The `validate` block
  * The `next_node` block
  * The `calculate` block
  * All subsequent questions and outcomes

__NOTE.__ `on_response` blocks are not named, because they don't automatically store a value in a state variable. In fact doing so is actively discouraged apart from when storing a calculator object in the first question of a flow:

```ruby
multiple_choice :question_1? do
  option :option_1
  option :option_2

  on_response do |response|
    self.calculator = ExampleCalculator.new
    calculator.question_1_response = response
  end

  next_node do
    if calculator.question_1_response == 'option_1'
      outcome :outcome_1
    else
      outcome :outcome_2
    end
  end
end

value_question :question_2? do
  on_response do |response|
    calculator.question_2_response = response
  end

  next_node do
    if calculator.question_1_response == 'option_1' && calculator.question_2_response == 'London'
      outcome :outcome_1
    else
      outcome :outcome_2
    end
  end
end
```

* `save_input_as` values are available in:
  * The `calculate` block
  * All subsequent questions and outcomes

* `calculate` values are available in:
  * All subsequent questions and outcomes

The flow below illustrates the data available to the different Question node methods.

```ruby
multiple_choice :question_1? do
  option :q1_option

  next_node do
    question :question_2?
  end

  calculate :q1_calculated_answer do
    'q1-calculated-answer'
  end
end

multiple_choice :question_2? do
  option :q2_option

  precalculate :q2_precalculated_answer do
    # responses            => ['q1_option']
    # q1_calculated_answer => 'q1-calculated-answer'

    'q2-precalculated-answer'
  end

  on_response do |response|
    # response                => 'q2_option'
    # responses               => ['q1_option']
    # q1_calculated_answer    => 'q1-calculated-answer'
    # q2_precalculated_answer => 'q2_precalculated_answer'

    self.q2_saved_response = response
  end

  validate do |response|
    # response                       => 'q2_option'
    # responses                      => ['q1_option']
    # q1_calculated_answer           => 'q1-calculated-answer'
    # q2_precalculated_answer        => 'q2-precalculated-answer'
    # q2_saved_response              => 'q2_option'
  end

  next_node do |response|
    # response                       => 'q2_option'
    # responses                      => ['q1_option']
    # q1_calculated_answer           => 'q1-calculated-answer'
    # q2_precalculated_answer        => 'q2-precalculated-answer'
    # q2_saved_response              => 'q2_option'
  end

  save_input_as :q2_answer

  calculate :q2_calculated_answer do |response|
    # response                       => 'q2_option'
    # responses                      => ['q1_option', 'q2_option']
    # q1_calculated_answer           => 'q1-calculated-answer'
    # q2_answer                      => 'q2_option'
    # q2_precalculated_answer        => 'q2-precalculated-answer'
    # q2_saved_response              => 'q2_option'
  end
end
```
