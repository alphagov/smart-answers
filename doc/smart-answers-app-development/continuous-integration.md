# Continuous integration

## Master

The [govuk_smart_answers master build](https://ci.integration.publishing.service.gov.uk/job/smartanswers/job/master/) is triggered by new commits on the `master` branch of the [GitHub repo](https://github.com/alphagov/smart-answers). It runs the [`Jenkinsfile`](https://github.com/alphagov/smart-answers/blob/master/Jenkinsfile). This script does the following:

* Attempts to merge the current branch (`master`) into `master` - this should always succeed and is effectively a no-op
* Checks out the latest [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas) which are used in a few of the tests
* Installs the bundled gems
* Runs RuboCop with the linting rules provided by the `rubocop-govuk` gem
* Runs the `test` rake task with `TEST_COVERAGE` enabled
* Pre-compiles assets

If any of these steps fails, the build fails-fast.

## Branches

[Branch builds](https://ci.integration.publishing.service.gov.uk/job/smartanswers/) are triggered by new commits on other branches of the [GitHub repo](https://github.com/alphagov/smart-answers).

Jenkins sends notifications to GitHub, so that the build status is displayed on [pull request pages](https://github.com/alphagov/smart-answers/pulls).

The attempt to merge the current branch into `master` may also fail if there are merge conflicts whereupon the merge is aborted and the script fails fast. If the merge succeeds then the script continues as for the main CI instance.
