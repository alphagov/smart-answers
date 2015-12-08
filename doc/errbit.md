# Errbit

Exceptions raised in preview, staging and production are sent to Errbit.

* [Preview Errbit][errbit-preview]
* [Staging Errbit][errbit-staging]
* [Production Errbit][errbit-prod]

You'll want to "watch" each of those instances in order to be emailed when an exception occurs.

Exceptions are automatically cleared on a new deployment.

## Known/Ignorable exceptions

It's unfortunate but we have a few known/ignorable exceptions that occur every so often. It's generally safe to ignore these but if we start seeing large numbers of them then they should be investigated.

### Slimmer errors when static/assets host can't be reached

These exceptions will often be seen together when network connectivity issues mean that the static/assets host can't be reached.

* `Slimmer::TemplateNotFoundException` ([example][slimmer-template-not-found-exception-example])

* `NoMethodError: undefined method '<<' for nil:NilClass` ([example][append-exception-example])

* `NoMethodError: undefined method 'replace' for nil:NilClass` ([example][replace-exception-example])

* `NoMethodError: undefined method 'attr' for nil:NilClass` ([example][attr-exception-example])

* `TypeError: wrong argument type nil (expected Data)` ([example][type-error-exception-example])

### Errors when GDS API host can't be reached

* `GdsApi::HTTPServerError` ([example][gds-api-http-server-error-example])

[errbit-preview]: https://errbit.preview.alphagov.co.uk/apps/533c2ee40da115303f0129a5
[errbit-staging]: https://errbit.staging.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f
[errbit-prod]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f
[append-exception-example]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f/problems/565056ee6578630639f57100
[replace-exception-example]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f/problems/565056f0657863063bc97700
[attr-exception-example]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f/problems/565056f26578630639267200
[type-error-exception-example]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f/problems/565056f4657863063bfc7700
[slimmer-template-not-found-exception-example]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f/problems/5653b200657863063b0d8000
[gds-api-http-server-error-example]: https://errbit.publishing.service.gov.uk/apps/533c35ae0da1159384044f5f/problems/5653ce3065786306f5e10200
