#!/bin/bash
bundle install

GOVUK_APP_DOMAIN=integration.publishing.service.gov.uk
PLEK_SERVICE_CONTENTAPI_URI=https://www.gov.uk/api
PLEK_SERVICE_STATIC_URI=https://assets-origin.integration.publishing.service.gov.uk

bundle exec rails s -p 3010 -b 0.0.0.0
