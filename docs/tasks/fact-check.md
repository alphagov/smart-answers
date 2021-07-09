# Deploying changes for fact-check

When making bigger changes that need to be tested or fact-checked before they
are deployed to GOV.UK you can make use of [Heroku Review apps][].
These are created automatically when a new PR is opened and will also be
automatically linked to from the PR. They will also update on each new commit
to the PR.

The main branch of Smart Answers is deployed to Heroku with each update and
this allows previewing draft Smart Answers. This is available at
https://smart-answers-preview.herokuapp.com/.

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

[Heroku Review]: https://devcenter.heroku.com/articles/github-integration-review-apps
