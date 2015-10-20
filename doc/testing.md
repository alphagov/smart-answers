# Testing

## External dependencies

Some of the smart-answers tests require PhantomJS to be [installed on your machine
natively](https://github.com/teampoltergeist/poltergeist/blob/master/README.md#installing-phantomjs).

Smart-answers also require the govuk-content-schemas repository which can
be [cloned](https://github.com/alphagov/govuk-content-schemas) into a sibling
directory, or a directory referenced using GOVUK_CONTENT_SCHEMAS_PATH.

## Executing tests

Run all tests by executing the following:

    bundle exec rake

## Regression tests

See [regression tests documentation](regression-tests.md).
