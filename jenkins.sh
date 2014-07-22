#!/bin/bash -x

set -e

bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development
export GOVUK_APP_DOMAIN=dev.gov.uk
export GOVUK_ASSET_HOST=http://static.dev.gov.uk

export DISPLAY=:99
bundle exec rake stats
RAILS_ENV=test bundle exec rake test

bundle exec rake assets:precompile
