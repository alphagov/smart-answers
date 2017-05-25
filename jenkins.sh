#!/bin/bash -x

set -e

# 1. This function first lists the branches available.
# 2. Finds the current branch (i.e starts with an asterisk).
# 3. Finds the value/group between the asterisk and forward slash.
# 4. Returns the value/group.
# For example for a branch named <smart-answer-name>/<description-of-task-or-feature>,
# This function will return <smart-answer-name> only.
parse_git_branch(){
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)\(\/.*\)/\1/'
}

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

git clean -fdx

# Clone govuk-content-schemas depedency for contract tests
rm -rf tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git tmp/govuk-content-schemas
(
  cd tmp/govuk-content-schemas
  git checkout ${SCHEMA_GIT_COMMIT:-"master"}
)
export GOVUK_CONTENT_SCHEMAS_PATH=tmp/govuk-content-schemas

bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment

export DISPLAY=:99

if [ -z "$RUN_REGRESSION_TESTS" ]; then
  bundle exec govuk-lint-ruby \
    --format clang

  RUN_REGRESSION_TESTS=`parse_git_branch` bundle exec ruby test/regression/smart_answers_regression_test.rb

  RAILS_ENV=test TEST_COVERAGE=true bundle exec rake test

  bundle exec rake assets:precompile
else
  bundle exec ruby test/regression/smart_answers_regression_test.rb
fi
