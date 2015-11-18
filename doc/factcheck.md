# Deploying changes for Factcheck

When making bigger changes that need to be tested or fact-checked before they are deployed to GOV.UK you'll need to deploy the branch with changes to Heroku.

## Deploying to Heroku

Start by creating a GitHub pull request with the changes you want to deploy. Add the ["Waiting on factcheck" label](https://github.com/alphagov/smart-answers/labels/Waiting%20on%20factcheck) to the pull request to let other developers know that it's not ready to be reviewed.

Make a note of the pull request number and use the `startup_heroku.sh` script to deploy your changes to Heroku:

    $ PR=<number-of-pull-request> ./startup_heroku.sh

This script will create and configure an app on Heroku, push the __current branch__ and open the marriage-abroad Smart Answer in the browser.

Once deployed you'll need to use the standard `git push` mechanism to deploy your changes.

    ./startup_heroku.sh

## Historical v2 workflow

__This is for reference only. This method is no longer used.__

The original method of fact checking changes to a Smart Answer was to:

* Copy the Smart Answer flow and associated YAML file and name them with a "-v2" suffix (see [PR #1587][pr-1587] for an example).

* Set the status of the v2 Smart Answer flow to `:draft`. This allowed it to be viewed in the preview environment but not in the production environment.

* Make the necessary changes the v2 copy of the Smart Answer.

* Ask the relevant parties to review the changes to the v2 copy deployed to preview.

* Replace the original Smart Answer with the v2 copy once we received the OK from the people fact-checking the changes (see [PR #1599][pr-1599] for an example).

This approach had a number of different problems, although the main ones were:

* We lost the history of the changes being made in the v2 "branch" when they were copied over the original Smart Answer.

* Intentional changes to the original Smart Answer could easily be lost when copying the v2 "branch" over the original.

[pr-1587]: https://github.com/alphagov/smart-answers/pull/1587/
[pr-1599]: https://github.com/alphagov/smart-answers/pull/1599/
