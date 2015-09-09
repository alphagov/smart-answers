#!/bin/bash

echo
echo "# Creating a new Heroku App"
echo
heroku apps:create --region eu

echo
echo "# Configuring Heroku ready for Smart Answers"
echo
heroku config:set \
GOVUK_APP_DOMAIN=preview.alphagov.co.uk \
PLEK_SERVICE_CONTENTAPI_URI=https://www.gov.uk/api \
PLEK_SERVICE_STATIC_URI=https://assets-origin.preview.alphagov.co.uk \
RUNNING_ON_HEROKU=true \
EXPOSE_GOVSPEAK=true \
ERRBIT_ENV=preview

echo
echo "# Pushing the current branch to Heroku's master"
echo
export CURRENT_BRANCH_NAME=`git branch | grep "^\*" | cut -d" " -f2`
git push heroku $CURRENT_BRANCH_NAME:master

echo
echo "# Opening Smart Answers"
echo "*NOTE.* You may have to refresh as the app can be slow to start"
echo
export HEROKU_URL=`heroku apps:info | grep "Web URL" | cut -c16-`
export SMART_ANSWER_TO_OPEN="marriage-abroad"
open $HEROKU_URL$SMART_ANSWER_TO_OPEN

echo
echo "*Set ERRBIT_API_KEY and ERRBIT_HOST manually to enable error reporting*"
echo "*You can find those key values on https://errbit.<environment>.alphagov.co.uk*"
echo "All done"
echo
