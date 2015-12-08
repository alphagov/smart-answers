# Viewing a Smart Answer as Govspeak

Seeing [Govspeak](https://github.com/alphagov/govspeak) markup of Smart Answer pages can be useful to content designers when preparing content change requests or developers inspecting generated Govspeak that later gets translated to HTML. This feature can be enabled by setting `EXPOSE_GOVSPEAK` to a non-empty value. It can be accessed by appending `.txt` to URLs (currently govspeak is available for landing and outcome pages, but not question pages).

## In Development

* [Marriage abroad landing page](http://smartanswers.dev.gov.uk/marriage-abroad.txt)
* [Marriage abroad outcome page](http://smartanswers.dev.gov.uk/marriage-abroad/y/afghanistan/uk/partner_other/opposite_sex.txt)

## In Preview environment

**Only outcomes pages can be rendered as Govspeak in Preview**. There's a [Trello card about this inconsistency](https://trello.com/c/qd5C7qDn/165-allow-landing-pages-to-be-rendered-as-govspeak-in-preview).

* [Marriage abroad outcome page](https://www.preview.alphagov.co.uk/marriage-abroad/y/afghanistan/uk/partner_other/opposite_sex.txt)
