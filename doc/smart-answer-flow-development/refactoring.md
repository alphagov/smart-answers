# Refactoring existing Smart Answers

Some Smart Answer flows contain a mix of concerns: routing logic, policy/calculator logic and presentation logic.

These concerns should really be split. Routing belongs in the flow, policy/calculator logic belongs in the calculator and presentation belongs in the ERB templates. You might think of the flow as the Controller, the calculator as the Model and the ERB template as the View in an MVC architecture.

We've refactored a number of these Smart Answers and have a rough set of steps that we follow:

* Remove unused code from the flow, e.g. unused `save_input_as` or `calculate` blocks. See commit [fe4014d7c007108f3daa07f1c5dd749f5de683a0](https://github.com/alphagov/smart-answers/commit/fe4014d7c007108f3daa07f1c5dd749f5de683a0) for an example.

* Include `ActiveModel::Model` in the calculator so that it's easy to instantiate it with a number of attributes set. See commit [f78671a062339ae97abb5cb267b55536233316c9](https://github.com/alphagov/smart-answers/commit/f78671a062339ae97abb5cb267b55536233316c9) for an example.

* Instantiate the calculator in a `on_response` block in the first question. See commit [0df6fd7df9a00ec882edf249eeaaa68a291633c5](https://github.com/alphagov/smart-answers/commit/0df6fd7df9a00ec882edf249eeaaa68a291633c5) for an example.

```ruby
value_question :first_question? do
  on_response do |response|
    self.calculator = ExampleCalculator.new
    calculator.first_response = response
  end
end
```

* Save the responses to questions on the calculator object using an `on_response` block rather than using `save_input_as`. See commit [b17128fb92b89941238a7e94b0c1abebe4351a83](https://github.com/alphagov/smart-answers/commit/b17128fb92b89941238a7e94b0c1abebe4351a83) for an example.

```ruby
value_question :subsequent_question? do
  on_response do |response|
    calculator.subsequent_response = response
  end
end
```

* Extract magic numbers into intention-revealing variables/constants. See commit [2e1f2ad117813cf0b8741ffbff6c711f5d838947](https://github.com/alphagov/smart-answers/commit/2e1f2ad117813cf0b8741ffbff6c711f5d838947) for an example.

* Move policy logic from the flow to the calculator. See commit [96f10c4c04bd88cc6506d74dad48989de7b7fa29](https://github.com/alphagov/smart-answers/commit/96f10c4c04bd88cc6506d74dad48989de7b7fa29) for an example.

* Move validation logic from the flow to the calculator. See commit [7833a2c4b5bed6e699a96a194a1c7663d35ec520](https://github.com/alphagov/smart-answers/commit/7833a2c4b5bed6e699a96a194a1c7663d35ec520) for an example.

* Move presentation from the flow/calculator to the ERB templates. See commit [a23e4c7ab8ed6b3ae4c53212d7cd4102fbeb1f37](https://github.com/alphagov/smart-answers/commit/a23e4c7ab8ed6b3ae4c53212d7cd4102fbeb1f37) for an example.

* Define `calculate` blocks as late as possible. 

[Pull request 2068][pr-2068] is a great example of incrementally applying the steps above to refactor the calculate-statutory-sick-pay Smart Answer. Pull requests [2095][pr-2095] and [1856][pr-1856] apply a similar refactoring to check-uk-visa and minimum-wage respectively.

[pr-1856]: https://github.com/alphagov/smart-answers/pull/1856
[pr-2068]: https://github.com/alphagov/smart-answers/pull/2068
[pr-2095]: https://github.com/alphagov/smart-answers/pull/2095
