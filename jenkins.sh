#!/bin/bash -x

set -e

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

git clean -fdx
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
export GOVUK_APP_DOMAIN=dev.gov.uk
export GOVUK_ASSET_HOST=http://static.dev.gov.uk

export DISPLAY=:99

if [ -z "$RUN_REGRESSION_TESTS" ]; then
  bundle exec govuk-lint-ruby \
    --diff --cached \
    --format clang

  RAILS_ENV=test TEST_COVERAGE=true bundle exec rake test

  bundle exec rake assets:precompile
else
  bundle exec ruby test/regression/smart_answers_regression_test.rb
fi
