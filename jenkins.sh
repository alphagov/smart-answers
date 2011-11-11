#!/bin/bash -x
source '/usr/local/lib/rvm'
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment --without=development

# DELETE STATIC SYMLINKS AND RECONNECT...
for dir in images javascript templates stylesheets; do
  rm /var/lib/jenkins/jobs/Smart_Answers/workspace/public/$dir
  ln -s /var/lib/jenkins/jobs/Static/workspace/public/$dir /var/lib/jenkins/jobs/Smart_Answers/workspace/public/$dir
done

export DISPLAY=:99
RAILS_ENV=test bundle exec rake test
RESULT=$?
exit $RESULT
