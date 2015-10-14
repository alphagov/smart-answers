# Continuous integration

## Main

The [govuk_smart_answers CI instance](https://ci-new.alphagov.co.uk/job/govuk_smart_answers/) is triggered by new commits on the `master` branch of the [GitHub repo](https://github.com/alphagov/smart-answers). It runs the [`jenkins.sh`](https://github.com/alphagov/smart-answers/blob/master/jenkins.sh) script with the `RUN_REGRESSION_TESTS` not set. This script does the following:

* Attempts to merge the current branch (`master`) into `master` - this should always succeed and is effectively a no-op
* Checks out the latest [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas) which are used in a few of the tests
* Installs the bundled gems
* Runs govuk-lint-ruby (see [Rubocop docs](rubocop.md))
* Runs the `test` rake task with `TEST_COVERAGE` enabled
* Pre-compiles assets

If any of these steps fails, the build fails-fast.

## Branches

The [govuk_smartanswers_branches CI instance](https://ci-new.alphagov.co.uk/job/govuk_smartanswers_branches/) is triggered by new commits on other branches of the [GitHub repo](https://github.com/alphagov/smart-answers). It runs the [`jenkins_branches.sh`](https://github.com/alphagov/smart-answers/blob/master/jenkins_branches.sh) script with the `RUN_REGRESSION_TESTS` not set.

This script calls the [`jenkins.sh`](https://github.com/alphagov/smart-answers/blob/master/jenkins.sh) script wrapping it in code which sends notifications to GitHub, so that the build status is displayed on [pull request pages](https://github.com/alphagov/smart-answers/pulls).

In this case the `jenkins.sh` script does the same as the [main CI instance](#main), but the attempt to merge the current branch into `master` may fail if there are merge conflicts whereupon the merge is aborted and the script fails fast.

If the merge succeeds then the script continues as for the main CI instance.

## Regression

The [govuk_smart_answers_regressions CI instance](https://ci-new.alphagov.co.uk/job/govuk_smart_answers_regressions/) is triggered periodically (currently every 2 hours). It runs the [`jenkins.sh`](https://github.com/alphagov/smart-answers/blob/master/jenkins.sh) script with the `RUN_REGRESSION_TESTS` set. This script does the following:

* Checks out the lastest [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas) which are used in a few of the tests
* Installs the bundled gems
* Runs the SmartAnswersRegressionTest for all flows

If any of these steps fails, the build fails-fast.
