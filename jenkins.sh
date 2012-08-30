#!/bin/bash -x
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development

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
