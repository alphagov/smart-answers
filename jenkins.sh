#!/bin/bash -x
source '/usr/local/lib/rvm'
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development

# DELETE STATIC SYMLINKS AND RECONNECT...
for dir in images javascripts templates stylesheets; do
  rm public/$dir
  ln -s ../../Static/workspace/public/$dir public/$dir
done

export DISPLAY=:99
RAILS_ENV=test bundle exec rake test
RESULT=$?
exit $RESULT
