# Deploying changes for Factcheck

When making bigger changes that need to be tested or fact-checked before they are deployed to GOV.UK you'll need to deploy the branch with changes to Heroku.

## Deploying to Heroku

Start by creating a GitHub pull request with the changes you want to deploy. Add the ["Waiting on factcheck" label](https://github.com/alphagov/smart-answers/labels/Waiting%20on%20factcheck) to the pull request to let other developers know that it's not ready to be reviewed.

Make a note of the pull request number and use the `startup_heroku.sh` script to deploy your changes to Heroku:

```bash
$ PR=<number-of-pull-request> ./startup_heroku.sh
```

This script will create and configure an app on Heroku, push the __current branch__ and open the marriage-abroad Smart Answer in the browser.

Once deployed you'll need to use the standard `git push` mechanism to deploy your changes.

```bash
./startup_heroku.sh
```

### Displaying rates for a specific date

The `RatesQuery` object is responsible for looking up the correct rates (in lib/data/rates) to display. By default, it'll lookup the rates for today but that can be overridden by setting the `RATES_QUERY_DATE` environment variable.

This is useful for previewing future rates on Heroku, e.g. when rates are being changed in the new tax year.

```bash
$ heroku config:set RATES_QUERY_DATE=<yyyy-mm-dd>
```
