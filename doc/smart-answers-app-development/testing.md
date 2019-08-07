# Testing

If you're writing a new smart answer or are [refactoring an existing one](refactoring.md) then you should be using the new approach to testing which we're gradually adopting. The idea is that with the various concerns better separated, we should be able to provide more test coverage at the unit-test level i.e. using the idea of a [Test Pyramid][].

Advantages:

* Avoids combinatorial explosion
* Tests are less brittle
* Easier to diagnose failing tests
* Faster test suite

## External dependencies

Some of the Smart Answers tests require PhantomJS to be [installed on your machine natively](https://github.com/teampoltergeist/poltergeist/blob/master/README.md#installing-phantomjs).

Smart Answers also require the `govuk-content-schemas` repository which can be [cloned](https://github.com/alphagov/govuk-content-schemas) into a sibling directory, or a directory referenced using `GOVUK_CONTENT_SCHEMAS_PATH`.

## New style

When we built the [part-year-profit-tax-credits][1], we adopted the following strategy:

### Unit tests

* [PartYearProfitTaxCreditsFlowTest][2]
  * This unit-tests the flow one node at a time
  * Tests the question routing logic
  * c.f. RSpec controller unit spec
* [PartYearProfitTaxCreditsViewTest][3]
  * This unit-tests the rendering of question and outcome pages one node at a time
  * Tests presentational logic
  * c.f. RSpec view unit spec
* [PartYearProfitTaxCreditsCalculatorTest][4]
  * This unit tests the policy logic
  * It sometimes stubs out methods in order to isolate specific parts of the logic
  * c.f. RSpec model unit spec

### Integration tests

* [PartYearProfitTaxCreditsCalculatorTest][5]
  * This tests the calculator as a whole and doesn't stub out any of its methods.
* [PartYearProfitTaxCreditsTest][6]
  * This checks that the flow and its component parts are wired up correctly.
  * It doesn't aim for 100% coverage, but just enough to exercise each node at least once.

## Old style

We previously had to use nested contexts to write integration tests around Smart Answers. This lead to deeply nested, hard to follow tests. We've removed the code that required this style and should no longer be writing these deeply nested tests.

* Flows that have a calculator also tend to have a unit test for that calculator.
* When we started doing significant refactoring of the app, we weren't happy that we had sufficient test coverage to support this work.
* Notably none of the tests actually *rendered* the question or outcome pages.
* We introduced the regression tests as a relatively quick way to improve the test coverage.
* The regression tests are only a temporary measure to help with the refactoring and have now been removed.

Here's an example Smart Answer flow and how the two approaches to testing differ:

```ruby
status :published

multiple_choice :question_1? do
  option :A
  option :B

  next_node do
    question :question_2?
  end
end

multiple_choice :question_2? do
  option :C
  option :D

  next_node do
    question :question_3?
  end
end

multiple_choice :question_3? do
  option :E
  option :F

  next_node do
    outcome :outcome_1
  end
end

outcome :outcome_1 do
end
```

### Good: Flattened test

This is how we should be writing integration tests for Smart Answer flows.

```ruby
should "exercise the example flow" do
  setup_for_testing_flow SmartAnswer::ExampleFlow

  assert_current_node :question_1?
  add_response :A
  assert_current_node :question_2?
  add_response :C
  assert_current_node :question_3?
  add_response :E
  assert_current_node :outcome_1
end
```

### DEPRECATED: A test using nested contexts

This is how we were previously writing integration tests for Smart Answer flows.

```ruby
setup do
  setup_for_testing_flow SmartAnswer::ExampleFlow
end

should "be on question 1" do
  assert_current_node :question_1?
end

context "when answering question 1" do
  setup do
    add_response :A
  end

  should "be on question 2" do
    assert_current_node :question_2?
  end

  context "when answering question 2" do
    setup do
      add_response :C
    end

    should "be on question 3" do
      assert_current_node :question_3?
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
```

[Test Pyramid]: http://martinfowler.com/bliki/TestPyramid.html
[1]: https://github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/part-year-profit-tax-credits.rb
[2]: https://github.com/alphagov/smart-answers/blob/master/test/unit/smart_answer_flows/part_year_profit_tax_credits_flow_test.rb
[3]: https://github.com/alphagov/smart-answers/blob/master/test/unit/smart_answer_flows/part_year_profit_tax_credits_view_test.rb
[4]: https://github.com/alphagov/smart-answers/blob/master/test/unit/calculators/part_year_profit_calculator_test.rb
[5]: https://github.com/alphagov/smart-answers/blob/master/test/integration/calculators/part_year_profit_calculator_test.rb
[6]: https://github.com/alphagov/smart-answers/blob/master/test/integration/smart_answer_flows/part_year_profit_tax_credits_test.rb
