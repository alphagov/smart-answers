# Storing data for later use

You can use the `precalculate`, `next_node_calculation`, `save_input_as` and `calculate` methods to store data for later use.

* `precalculate` values are available in:
  * The question template
  * The `next_node_calculation` block
  * The `validate` block
  * The `next_node` block
  * The `calculate` block
  * All subsequent questions and outcomes

__NOTE.__ `precalculate` blocks are not evaluated in the first question. This is because they're evaluated during the transition of one question to the next.

* `next_node_calculation` values are available in:
  * The `validate` block
  * The `next_node` block
  * The `calculate` block
  * All subsequent questions and outcomes

* `save_input_as` values are available in:
  * The `calculate` block
  * All subsequent questions and outcomes

* `calculate` values are available in:
  * All subsequent questions and outcomes

The flow below illustrates the data available to the different Question node methods.

```ruby
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
```
