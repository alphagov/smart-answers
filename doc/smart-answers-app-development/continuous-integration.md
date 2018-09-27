# Continuous integration

## Master

The [govuk_smart_answers master build](https://ci.integration.publishing.service.gov.uk/job/smartanswers/job/master/) is triggered by new commits on the `master` branch of the [GitHub repo](https://github.com/alphagov/smart-answers). It runs the [`Jenkinsfile`](https://github.com/alphagov/smart-answers/blob/master/Jenkinsfile). The `RUN_REGRESSION_TESTS` parameter is not set but the `Jenkinsfile` is configured so that regression tests are always run for builds of `master`. This script does the following:

* Attempts to merge the current branch (`master`) into `master` - this should always succeed and is effectively a no-op
* Checks out the latest [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas) which are used in a few of the tests
* Installs the bundled gems
* Runs govuk-lint-ruby (see [Rubocop docs](rubocop.md))
* Runs the `test` rake task with `TEST_COVERAGE` enabled
* Runs the `SmartAnswersRegressionTest` for all flows
* Pre-compiles assets

If any of these steps fails, the build fails-fast.

## Branches

[Branch builds](https://ci.integration.publishing.service.gov.uk/job/smartanswers/) are triggered by new commits on other branches of the [GitHub repo](https://github.com/alphagov/smart-answers). They run the [`Jenkinsfile`](https://github.com/alphagov/smart-answers/blob/master/Jenkinsfile) with the `RUN_REGRESSION_TESTS` parameter not set.

Jenkins sends notifications to GitHub, so that the build status is displayed on [pull request pages](https://github.com/alphagov/smart-answers/pulls).

In this case the `Jenkins` script does the same as the [main CI build](#main) except for regression tests, which are skipped for branch builds to speed up build times.

To run regression tests on a branch, find the branch's pipeline build in Jenkins and click "Build with parameters" in the sidebar. Tick the `RUN_REGRESSION_TESTS` parameter and leave the other parameters with their default values.

The attempt to merge the current branch into `master` may also fail if there are merge conflicts whereupon the merge is aborted and the script fails fast. If the merge succeeds then the script continues as for the main CI instance.
