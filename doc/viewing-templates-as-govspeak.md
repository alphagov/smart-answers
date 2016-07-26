# Viewing a Smart Answer as Govspeak

Seeing [Govspeak](https://github.com/alphagov/govspeak) markup of Smart Answer pages can be useful to content designers when preparing content change requests or to developers inspecting generated Govspeak that later gets translated to HTML.

This feature can be enabled by setting `EXPOSE_GOVSPEAK` to a non-empty value. It is enabled by default in the Integration environment and in Heroku apps deployed via the `startup_heroku.sh` script.

The Govspeak version of the pages can be accessed by appending `.txt` to URLs.

## In Development environment

* [Marriage abroad landing page](http://smartanswers.dev.gov.uk/marriage-abroad.txt)
* [Marriage abroad question page](http://smart-answers.dev.gov.uk/marriage-abroad/y.txt)
* [Marriage abroad outcome page](http://smartanswers.dev.gov.uk/marriage-abroad/y/afghanistan/uk/partner_other/opposite_sex.txt)

## In Integration environment

**It's not currently possible to access the Govspeak version of landing pages in the Integration environment.** There's a [Trello card about this inconsistency](https://trello.com/c/qd5C7qDn/165-allow-landing-pages-to-be-rendered-as-govspeak-in-integration).

* [Marriage abroad question page](https://www-origin.integration.publishing.service.gov.uk/marriage-abroad/y.txt)
* [Marriage abroad outcome page](https://www-origin.integration.publishing.service.gov.uk/marriage-abroad/y/afghanistan/uk/partner_other/opposite_sex.txt)
