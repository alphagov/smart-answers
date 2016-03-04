# Refactoring existing Smart Answers

Some Smart Answer flows contain a mix of concerns: routing logic, policy/calculator logic and presentation logic.

These concerns should really be split. Routing belongs in the flow, policy/calculator logic belongs in the calculator and presentation belongs in the ERB templates. You might think of the flow as the Controller, the calculator as the Model and the ERB template as the View in an MVC architecture.

We've refactored a small number of these Smart Answers and have a rough set of steps that we follow:

* Remove unused code from the flow, e.g. unused `save_input_as`, `precalculate` or `calculate` blocks. See commit fe4014d7c007108f3daa07f1c5dd749f5de683a0 for an example.

* Include `ActiveModel::Model` in the calculator so that it's easy to instantiate it with a number of attributes set. See commit f78671a062339ae97abb5cb267b55536233316c9 for an example.

* Instantiate the calculator in a `next_node_calculation` block in the first question. See commit 6114c5fc55bfdaff52501e2a19dead35ebb42f13 for an example.

* Save the responses to questions on the calculator object rather than using `save_input_as`. See commit 64c60baf42e726fa234e579a04c36bc0da0fa3fc for an example.

* Extract magic numbers into intention-revealing variables/constants. See commit 2e1f2ad117813cf0b8741ffbff6c711f5d838947 for an example.

* Move policy logic from the flow to the calculator. See commit 96f10c4c04bd88cc6506d74dad48989de7b7fa29 for an example.

* Move validation logic from the flow to the calculator. See commit 7833a2c4b5bed6e699a96a194a1c7663d35ec520 for an example.

* Move presentation from the flow/calculator to the ERB templates. See commit a23e4c7ab8ed6b3ae4c53212d7cd4102fbeb1f37 for an example.

* Define `calculate` blocks as late as possible. If something is only required by a single outcome then use a `precalculate` block in that outcome rather than defining it in a `calculate` block earlier in the flow. See commit c98c60ddfeed70c6d60b89329f0e8fe3e030a171 for an example.

[Pull request 2068][pr-2068] is a great example of incrementally applying the steps above to refactor the calculate-statutory-sick-pay Smart Answer. Pull requests [2095][pr-2095] and [1856][pr-1856] apply a similar refactoring to check-uk-visa and minimum-wage respectively.

[pr-1856]: https://github.com/alphagov/smart-answers/pull/1856
[pr-2068]: https://github.com/alphagov/smart-answers/pull/2068
[pr-2095]: https://github.com/alphagov/smart-answers/pull/2095
