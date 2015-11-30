# Storing data for later use

You can use the `precalculate`, `next_node_calculation`, `save_input_as` and `calculate` methods to store data for later use.

Use `precalculate` or `next_node_calculation` to store data for use within the same node.

Use `save_input_as` to store the answer to the question for use within subsequent nodes.

Use `calculate` to store data for use within subsequent nodes.

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
