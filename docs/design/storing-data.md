# Storing data for later use

You can use the `on_response` method to store data for later use. These values are stored in the state and are available in the rest of the flow and in the ERB templates.

* `on_response` values are available in:
  * The `validate` block
  * The `next_node` block
  * All subsequent questions and outcomes

__NOTE.__ `on_response` blocks are not named, because they don't automatically store a value in a state variable. In fact doing so is actively discouraged apart from when storing a calculator object in the first question of a flow:

```ruby
radio :question_1? do
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

The flow below illustrates the data available to the different Question node methods.

```ruby
radio :question_1? do
  option :q1_option

  next_node do
    question :question_2?
  end
end

radio :question_2? do
  option :q2_option

  on_response do |response|
    # response                => 'q2_option'
    # responses               => ['q1_option']

    self.q2_saved_response = response
  end

  validate do |response|
    # response                       => 'q2_option'
    # responses                      => ['q1_option']
    # q2_saved_response              => 'q2_option'
  end

  next_node do |response|
    # response                       => 'q2_option'
    # responses                      => ['q1_option']
    # q2_saved_response              => 'q2_option'
  end
end
```
