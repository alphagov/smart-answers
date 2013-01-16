#!/bin/bash -x
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development
export GOVUK_APP_DOMAIN=dev.gov.uk
export GOVUK_ASSET_HOST=http://static.dev.gov.uk

# DELETE STATIC SYMLINKS AND RECONNECT...
for d in images javascripts templates stylesheets; do
  rm public/$d
  ln -s ../../Static/public/$d public/
done

export DISPLAY=:99
bundle exec rake stats
RAILS_ENV=test bundle exec rake test
RESULT=$?
exit $RESULT
