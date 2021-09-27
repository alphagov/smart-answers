# ADR 3: Testing Flows

Date: 2021-06-29

## Context

An individual Smart Answer is defined by a Flow, this is a class which defines the questions, outcomes and associated logic for the journey a user takes through a Smart Answer. There are currently 3 different approaches used for testing a Flow and none of these are applied consistently across all of them. This ADR concerns itself with the definition of an approach that can consolidate this inconsistency.

The existing approaches are:

### [Flow integration tests](https://github.com/alphagov/smart-answers/tree/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/integration/smart_answer_flows)

These tests:

- are widely adopted, 31 / 36 Flows have tests
- are insufficient as a full testing mechanism - nearly all tests will still pass despite corresponding ERB file problems (such as syntax errors or missing files)
- are caught between two styles - most tests involve [heavy context nesting](https://github.com/alphagov/smart-answers/blob/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/integration/smart_answer_flows/inherits_someone_dies_without_will_test.rb#L141-L291) though a ["new" (introduced in 2015) approach](https://github.com/alphagov/smart-answers/blob/b02da332a25f0a61c37a1c4991319639809fcde2/docs/testing/testing.md#new-style) [removes this nesting](https://github.com/alphagov/smart-answers/blob/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/integration/smart_answer_flows/part_year_profit_tax_credits_test.rb#L33-L43)

### [Flow unit tests](https://github.com/alphagov/smart-answers/tree/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/unit/smart_answer_flows)

These tests:

- are intended as a complement to Flow integration tests with individual tests for [Flow](https://github.com/alphagov/smart-answers/blob/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/unit/smart_answer_flows/part_year_profit_tax_credits_flow_test.rb) and [ERB files](https://github.com/alphagov/smart-answers/blob/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/unit/smart_answer_flows/part_year_profit_tax_credits_view_test.rb)
- have moderate adoption, 10 / 36 Flows have flow tests, 3 / 36 Flows have view tests
- duplicate the assertions between Flow unit tests and Flow integration tests

### [RSpec feature tests](https://github.com/alphagov/smart-answers/tree/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/spec/features/flows)

These tests:

- have low adoption, 5 / 36 Flows have tests
- are built upon RSpec test framework which is [being removed from Smart Answers](https://github.com/alphagov/smart-answers/issues/5350)
- exercise a full integration (including ERB files) by exercising and asserting via HTML output
- are significantly slower than other test approaches - testing through Rails requests is [approximately 50x slower](https://github.com/alphagov/smart-answers/pull/5394)

## Decision

We have decided to adopt a new testing approach that will supersede the aforementioned approaches to testing Smart Answer Flows. The goals of this new approach are to provide:

- tests that are fast to run
- assertions made at an ERB level (to prove their execution)
- a method to achieve full (or at least very high) coverage of Flow files
- easy to understand tests (relatively, given how hard Smart Answers can be to understand)
- relatively low levels of tedium/repetition in reading/writing tests (ideally length of test flow file is within 2x the flow file length)
- testing approaches that are consistent across different flow approaches (URI path, query string and session)

Following [two](https://github.com/alphagov/smart-answers/pull/5394) [rounds](https://github.com/alphagov/smart-answers/pull/5440) of feedback we've established that the new approach will:

- consolidate integration and unit testing to a single approach, similar to Rails' controller testing (with a similar emphasis on integration testing), since there is high possibility of tedious levels of duplication between multiple files
- have a boundary of testing the Flow and its contents, explicitly not testing earlier considerations such as routing or controller - this is due to them being tested separately and the performance advantages gained from not including them
- not assert directly on ERB output unless there is logic in ERB files (instead asserting they output something to prove no syntax errors), to reduce test verbosity and friction when copy changes
- test Flows in a style organised around the nodes (questions and outcomes), for understandability of what code is being tested:
  - start pages will be tested to [assert they have a title and a body](#set-up-and-start-page)
  - questions will test [all subsequent nodes are reachable](#asserting-a-question-goes-to-a-next-node) and [any validations](#testing-validation), they may be used to test calculators for complex scenarios (in simple scenarios they would already be tested implicitly), however the emphasis is on testing user visible scenarios
  - outcomes will only be tested explicitly [when there is specific logic for them](#testing-logic-in-an-outcome), they will already be tested implicitly for questions reaching outcomes


This approach offers a number of advantages over the existing testing approaches, but it does also arrive with some concerns which are noted for prosterity. These concerns are:

- setting up a node for testing requires a potentially large number of previous responses to be set, this may be verbose and repetitive - an alternative is the more contrived setup of [unit flow tests](https://github.com/alphagov/smart-answers/blob/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/test/unit/smart_answer_flows/part_year_profit_tax_credits_flow_test.rb#L116-L120) which was rejected for being less representative of a user journey
- the bespoke assertions are intended to assist with brevity due to the high level of repetition in flow tests, this may come at an expense of understandability
- there is a relatively high level of duplication between what is written in a `should` block and what is asserted - a [shoulda](https://github.com/thoughtbot/shoulda) approach was explored and [rejected](https://github.com/alphagov/smart-answers/pull/5440/commits/975dfeb34f8871a1ddfc30f65f36ff8cd17d1496) due to challenges reproducing failures
- the coverage tool used, SimpleCov, does not provide [coverage data for ERB files](https://github.com/simplecov-ruby/simplecov/issues/38) which means we can't monitor the degree of coverage of those files - there doesn't seem to be a well maintained coverage tool that offers this for Ruby

## Status

Accepted

## Consequences

There will be new tests written for all of the Smart Answer Flows. These tests will be written using Minitest and will be stored in a new directory `test/flows`. This has been chosen to reflect that these tests are not strictly unit or integration tests.

To pair with the test location, the existing Flow files (including ERB templates) will be moved from their location in `lib/smart_answer_flows` to a new location in `app/flows`. This will better suit their status as the main business logic of the application and reflect that they (and their views) isn't library code and an `app` location is a more conventional place for ERB files to reside.

Existing tests in `test/integration/smart_answer_flows`, `test/unit/smart_answer_flows` and `spec/features/flows` will be removed gradually with the introduction of the new tests in `test/flows`. Once all the tests are removed their directories will be deleted. This will contribute towards [the removal of RSpec](https://github.com/alphagov/smart-answers/issues/5350).

Prior to the introduction of new tests the existing minitest flow tests will be amended to ensure there aren't namespace collisions with the new tests (for example `FlowTestHelper` will likely collide as well as some test names such as `LandlordImmigrationCheckFlowTest`).

Finally the [testing documentation](https://github.com/alphagov/smart-answers/blob/93f34cae3eb746b5b08d78b6ea6b7d5c1dfbbc18/docs/testing/testing.md) will be amended to reflect the new approach.

## Appendix

### Syntax examples

#### Set up and start page

```ruby
class ExampleFlowTest < ActiveSupport::TestCase
  include ExperimentalFlowTestHelper

  setup { testing_flow SmartAnswer::ExampleFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  # ...
end
```

#### Asserting a question goes to a next node

```ruby
  context "question: receiving_non_exemption_benefits?" do
    setup do
      testing_node :receiving_non_exemption_benefits?
      add_responses receive_housing_benefit?: "yes",
                    working_tax_credit?: "no",
                    receiving_exemption_benefits?: []
    end

    should "render question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of housing_benefit_amount? for an empty response" do
        assert_next_node :housing_benefit_amount?, for_response: []
      end

      should "have a next node based on the response" do
        assert_next_node :bereavement_amount?, for_response: %w[bereavement child_benefit]
      end
    end
  end
```

#### Testing validation

```ruby
  context "question: shift_worker_hours_per_shift?" do
    setup do
      testing_node :shift_worker_hours_per_shift?
      add_responses basis_of_calculation?: "shift-worker",
                    shift_worker_basis?: "full-year"
    end

    should "render question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for hours below 0" do
        assert_invalid_response "-1"
      end

      should "be invalid for hours above 24" do
        assert_invalid_response "25"
      end
    end

    context "next_node" do
      should "have a next node of shift_worker_shifts_per_shift_pattern?" do
        assert_next_node :shift_worker_shifts_per_shift_pattern?, for_response: "8"
      end
    end
  end
```

#### Testing logic in an outcome

```ruby
  context "outcome: results" do
    setup { testing_node :results }

    should "render feeling unsafe help when the appropriate responses are given" do
      add_responses need_help_with: %w[feeling_unsafe],
                    feel_unsafe: "yes",
                    nation: "england"

      assert_rendered_outcome text: "If you feel unsafe where you live or you’re worried about someone else"
    end
  end
```
