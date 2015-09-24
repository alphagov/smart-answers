# Deploying changes for Factcheck

When making bigger changes that need to be tested or fact-checked before they are deployed to GOV.UK it is best to deploy the branch with changes to Heroku.

If you open a PR to review those changes, make sure to mention if it's being fact-checked and should not be merged to master until that's done.

## Deploying to Heroku

The 'startup_heroku.sh' shell script will create and configure an app on Heroku, push the __current branch__ and open the marriage-abroad Smart Answer in the browser.

Once deployed you'll need to use the standard `git push` mechanism to deploy your changes.

    ./startup_heroku.sh
