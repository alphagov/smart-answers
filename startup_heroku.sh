#!/bin/bash

if [ -z "$PR" ];
then
  echo "Usage: PR=<pull-request-number> ./startup_heroku.sh"
  exit 1
fi

export APP_NAME="smart-answers-pr-$PR"
export HEROKU_REMOTE="heroku-$APP_NAME"

echo
echo "# Creating a new Heroku App"
echo
heroku apps:create --region eu --remote $HEROKU_REMOTE $APP_NAME

echo
echo "# Configuring Heroku ready for Smart Answers"
echo
heroku config:set \
--app $APP_NAME \
GOVUK_APP_DOMAIN=integration.publishing.service.gov.uk \
PLEK_SERVICE_CONTENT_STORE_URI=https://www.gov.uk/api \
PLEK_SERVICE_STATIC_URI=https://assets-origin.integration.publishing.service.gov.uk/ \
RUNNING_ON_HEROKU=true \
EXPOSE_GOVSPEAK=true \

echo
echo "# Pushing the current branch to Heroku's master"
echo
export CURRENT_BRANCH_NAME=`git branch | grep "^\*" | cut -d" " -f2`
git push $HEROKU_REMOTE $CURRENT_BRANCH_NAME:master

export HEROKU_URL=`heroku apps:info --app $APP_NAME | grep "Web URL" | cut -c16-`
export SMART_ANSWER_TO_OPEN="marriage-abroad"
if type open 2>/dev/null; then
    echo
    echo "# Opening Smart Answers"
    echo "*NOTE.* You may have to refresh as the app can be slow to start"
    echo
    open $HEROKU_URL$SMART_ANSWER_TO_OPEN
else
    echo
    echo "# Smart Answers URL"
    echo "*NOTE.* You may have to refresh as the app can be slow to start"
    echo
    echo $HEROKU_URL$SMART_ANSWER_TO_OPEN
fi

echo "All done"
echo
