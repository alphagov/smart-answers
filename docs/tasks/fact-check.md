# Deploying changes for fact-check

When making bigger changes that need to be tested or fact-checked before they
are deployed to GOV.UK you can make use of [Heroku Review apps][].
These are created automatically when a new PR is opened and will also be
automatically linked to from the PR. They will also update on each new commit
to the PR.

The main branch of Smart Answers is deployed to Heroku with each update and
this allows previewing draft Smart Answers. This is available at
https://govuk-smart-answers.herokuapp.com/.

## Displaying rates for a specific date

Smart Answers are often used to illustrate certain costs or benefits applicable
on a particular date. These are determined by looking up the correct rates (in
[`config/smart_answers/rates`](../../config/smart_answers/rates)) to display for the current date.
When testing upcoming changes to rates you may want to simulate how they will
appear on a particular date, this can be achieved by setting the
`RATES_QUERY_DATE` environment variable.

To apply this to a particular review app you can set a value for this
environment variable in the [`app.json`](../../app.json), for example:
`"RATES_QUERY_DATE": "2020-04-01"` - don't forget to remove this before
merging.

**Note** This will only work if your review app has not yet been created. Pushing
a change to an app.json after a review app has been created will not update the
environment variables. 

If you want to do change the variable after your review app has been deployed, 
you'll have to manually set the  environment variable like so (where `$DATE` is 
the date you want to set and `$APP` is the name of the review app (e.g. 
`smart-answers-pr-7132`)):

```bash
heroku config:set RATES_QUERY_DATE=$DATE -a $APP
```

_If you're not already logged in, you will be prompted to log in to Heroku via your 
web browser. This assumes you have [access to the shared Heroku account][] 
and [have the Heroku CLI installed][]._

[Heroku Review]: https://devcenter.heroku.com/articles/github-integration-review-apps
[access to the shared Heroku account]: https://docs.publishing.service.gov.uk/manual/heroku.html
[have the Heroku CLI installed]: https://devcenter.heroku.com/articles/heroku-cli
