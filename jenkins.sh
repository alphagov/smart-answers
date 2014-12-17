#!/bin/bash -x

set -e

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development
export GOVUK_APP_DOMAIN=dev.gov.uk
export GOVUK_ASSET_HOST=http://static.dev.gov.uk

export DISPLAY=:99
RAILS_ENV=test SPEC_REPORTER=true bundle exec rake

bundle exec rake assets:precompile
