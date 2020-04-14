# Viewing a Smart Answer as Govspeak

Seeing [Govspeak](https://github.com/alphagov/govspeak) markup of Smart Answer pages can be useful to content designers when preparing content change requests or to developers inspecting generated Govspeak that later gets translated to HTML.

This feature can be enabled by setting `EXPOSE_GOVSPEAK` to a non-empty value. It is enabled by default in a development environment.

The Govspeak version of the pages can be accessed by appending `.txt` to URLs.

## Example URLs for a development environment

* [Marriage abroad landing page](http://smart-answers.dev.gov.uk/marriage-abroad.txt)
* [Marriage abroad question page](http://smart-answers.dev.gov.uk/marriage-abroad/y.txt)
* [Marriage abroad outcome page](http://smart-answers.dev.gov.uk/marriage-abroad/y/afghanistan/uk/partner_other/opposite_sex.txt)
