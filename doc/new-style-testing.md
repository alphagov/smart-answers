# New-style Testing

## Introduction

If you're writing a new smart answer or are [refactoring an existing one](refactoring.md) then you should be using the new approach to testing which we're gradually adopting. The idea is that with the various concerns better separated, we should be able to provide more test coverage at the unit-test level i.e. using the idea of a [Test Pyramid][].

### Advantages

* Avoids combinatorial explosion
* Tests are less brittle
* Easier to diagnose failing tests
* Faster test suite

## New style

When we built the [part-year-profit-tax-credits][3], we adopted the following strategy:

### Unit tests

* [PartYearProfitTaxCreditsFlowTest][4]
  * This unit-tests the flow one node at a time
  * Tests the question routing logic
  * c.f. RSpec controller unit spec
* [PartYearProfitTaxCreditsViewTest][5]
  * This unit-tests the rendering of question and outcome pages one node at a time
  * Tests presentational logic
  * c.f. RSpec view unit spec
* [PartYearProfitTaxCreditsCalculatorTest][6]
  * This unit tests the policy logic
  * It sometimes stubs out methods in order to isolate specific parts of the logic
  * c.f. RSpec model unit spec

### Integration tests

* [PartYearProfitTaxCreditsCalculatorTest][7]
  * This tests the calculator as a whole and doesn't stub out any of its methods.
* [PartYearProfitTaxCreditsTest][8]
  * This checks that the flow and its component parts are wired up correctly.
  * It doesn't aim for 100% coverage, but just enough to exercise each node at least once.


### Regression tests

* None - we felt that the other tests gave sufficient coverage.

Note: The `part-year-profit-tax-credits` flow was relatively content-light. It remains to be seen how we would go about testing a more content-heavy flow e.g. `marriage-abroad`. However, I still doubt we'll want any tests as brittle or comprehensive as the current regression tests.

## Old style

* Previously most of the test coverage for a flow was provided by a single integration test often with [lots of nested contexts](testing.md#deprecated-a-test-using-nested-contexts).
* Flows that have a calculator also tend to have a unit test for that calculator.
* When we started doing significant refactoring of the app, we weren't happy that we had sufficient test coverage to support this work.
* Notably none of the tests actually *rendered* the question or outcome pages.
* So at this point we introduced the [regression tests](regression-tests.md) as a relatively quick way to improve the test coverage.
* However, the intention has always been that these regression tests are only a temporary measure.

Here are the tests for the [calculate-your-child-maintenance][0] flow:

### Unit tests

* [ChildMaintenanceCalculatorTest][1]

### Integration tests

* [CalculateChildMaintentanceTest][2]

### Regression tests

* `$ RUN_REGRESSION_TESTS=calculate-statutory-sick-pay ruby test/regression/smart_answers_regression_test.rb`

[Test Pyramid]: http://martinfowler.com/bliki/TestPyramid.html
[0]: https://github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/calculate-your-child-maintenance.rb
[1]: https://github.com/alphagov/smart-answers/blob/master/test/unit/calculators/child_maintenance_calculator_test.rb
[2]: https://github.com/alphagov/smart-answers/blob/master/test/integration/smart_answer_flows/calculate_your_child_maintenance_test.rb
[3]: https://github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/part-year-profit-tax-credits.rb
[4]: https://github.com/alphagov/smart-answers/blob/master/test/unit/smart_answer_flows/part_year_profit_tax_credits_flow_test.rb
[5]: https://github.com/alphagov/smart-answers/blob/master/test/unit/smart_answer_flows/part_year_profit_tax_credits_view_test.rb
[6]: https://github.com/alphagov/smart-answers/blob/master/test/unit/calculators/part_year_profit_calculator_test.rb
[7]: https://github.com/alphagov/smart-answers/blob/master/test/integration/calculators/part_year_profit_calculator_test.rb
[8]: https://github.com/alphagov/smart-answers/blob/master/test/integration/smart_answer_flows/part_year_profit_tax_credits_test.rb
