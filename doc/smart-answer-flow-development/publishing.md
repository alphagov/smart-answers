### Publishing

Changes to smart answer pages need to be sent to be sent to the `content store` for them to appear on GOV.UK.

The [rake task `publishing_api:sync_all`](https://github.com/alphagov/smart-answers/blob/master/lib/tasks/publishing_api.rake) needs to be run once you have deployed your changes in each environment and can be done in [Jenkins](https://deploy.integration.publishing.service.gov.uk/job/run-rake-task/parambuild/?TARGET_APPLICATION=smartanswers&MACHINE_CLASS=calculators_frontend&RAKE_TASK=publishing_api:sync_all).
