# Environments

Smart Answers are available in Integration (e.g. [marriage-abroad][marriage-abroad-integration]), Staging (e.g. [marriage-abroad][marriage-abroad-staging]) and Production (e.g. [marriage-abroad][marriage-abroad-production]).

## Integration

Integration is deployed to automatically after a successful build of the master branch on Jenkins.

Integration differs from Staging and Production in that it'll show draft Smart Answers and allow you to [display outcomes as Govspeak](viewing-templates-as-govspeak.md).

## Staging

Staging is deployed to manually during the [deployment process][deployment-doc]. We check that everything is working as expected before deploying to production.

## Production

Production is deployed to manually during the deployment process, once we're happy that the deployment to Staging has worked as expected.

[deployment-doc]: deploying.md
[marriage-abroad-integration]: https://www-origin.integration.publishing.service.gov.uk/marriage-abroad
[marriage-abroad-staging]: https://www.staging.publishing.service.gov.uk/marriage-abroad
[marriage-abroad-production]: https://www.gov.uk/marriage-abroad
