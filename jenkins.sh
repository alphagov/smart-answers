#!/bin/bash -x
source '/usr/local/lib/rvm'
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment

# DELETE STATIC SYMLINKS AND RECONNECT...
for dir in images javascript templates stylesheets; do
  rm /var/lib/jenkins/jobs/Smart_Answers/workspace/public/$dir
  ln -s /var/lib/jenkins/jobs/Static/workspace/public/$dir /var/lib/jenkins/jobs/Smart_Answers/workspace/public/$dir
done

bundle exec rake ci:setup:testunit test:units test:functionals
RESULT=$?
exit $RESULT
