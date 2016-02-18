#!/bin/bash
bundle install

export GOVUK_APP_DOMAIN=integration.publishing.service.gov.uk
export PLEK_SERVICE_CONTENTAPI_URI=https://www.gov.uk/api
export PLEK_SERVICE_STATIC_URI=https://assets-origin.integration.publishing.service.gov.uk

bundle exec rails s -p 3010 -b 0.0.0.0
