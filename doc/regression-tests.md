# Regression tests

The project includes a set of regression tests. These tests are not *normally* run as part of the standard build, because they take a long time to run. You can run just the regression tests with the following command:

    $ RUN_REGRESSION_TESTS=true ruby test/regression/smart_answers_regression_test.rb

You can run just the regression tests for a single flow using this command:

    $ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb

Note that the `RUN_REGRESSION_TESTS` environment variable can also be used in conjunction with the rake `test` task if you want to force regression tests to run as part of the standard build.

By default most of the assertions in the regression tests are combined into a single assertion at the end. If you want the regression tests to fail fast then set `ASSERT_EACH_ARTEFACT=true`. However, you should note that this more than doubles the time it takes them to run.

Running the test re-generates a set of HTML/Govspeak files in `test/artefacts` based on the files in `test/data`.

## Test data

* `<smart-answer-flow-name>-questions-and-responses.yml` - defines a set of responses to the flow's questions
* `<smart-answer-flow-name>-responses-and-expected-results.yml` - a record of the question & outcome nodes visited when the above responses are applied combinatorially
* `<smart-answer-flow-name>-files.yml` - checksum data (see below)

## Artefacts

The following artefacts are saved in `test/artefacts`:

* `<smart-answer-flow-name>/<smart-answer-flow-name>.txt` - rendered Govspeak for landing page
* `<smart-answer-flow-name>/<responses-sequence>.html` - rendered HTML for question page
* `<smart-answer-flow-name>/<responses-sequence>.txt` - rendered Govspeak for outcome pages

The `<response-sequence>` is a forward-slash separated list of responses which closely relates to the URL paths to question & outcome pages in the app.

The regression test fails if any of the following is true:

* the newly generated artefact files differ at all from the committed files
* not all nodes are exercised by the test data
* the checksum data is out-of-date (see below)

If you've added extra questions, responses or outcomes, then you should change the `test/data` files to exercise the new paths through the flow. See the instructions for [adding new regression tests](adding-new-regression-tests.md)

If there's a difference in the artefacts, you need to carefully review the changes to the artefacts to make sure they all relate to the changes you have made before committing them.

## Checksums

Checksums for all flow-specific files are stored in a YAML file:

    test/data/<smart-answer-flow-name>-files.yml

Once you're happy that the changes to the artefacts correspond to the changes you intended to make, you can update the checksums using the following command:

    $ rails r script/generate-checksums-for-smart-answer.rb <smart-answer-flow-name>

When you've resolved all these issues, you should be able to run the regression tests for the flow as before and all the tests should pass:

    $ RUN_REGRESSION_TESTS=<smart-answer-flow-name> ruby test/regression/smart_answers_regression_test.rb

## Automatic trigger

The regression test for a given flow are triggered automatically when you run the rake `test` task if you've made changed to any of the files whose checksums are listed in `test/data/<smart-answer-flow-name>-files.yml`. Although this won't always trigger the regression test when it should be run, it covers most common scenarios.

If you've added new classes, modules or data which is used by a flow, you should add the relevant files to the checksums file.

## Continuous integration

The [main CI instance](doc/continuous-integration.md#main) and the [corresponding branches one](doc/continuous-integration.md#branches) run the rake `test` task and so work in the same way as above.

We also have a [separate CI instance](doc/continuous-integration.md#regression) which runs **all** the regression tests every so often. This should catch any scenarios missed by the automatic trigger.
