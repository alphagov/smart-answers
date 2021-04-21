//= require govuk_publishing_components/lib
//= require govuk_publishing_components/components/button
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/details
//= require govuk_publishing_components/components/feedback
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/print-link
//= require govuk_publishing_components/components/radio
//= require govuk_publishing_components/components/step-by-step-nav
//= require helpers
//= require components/hide-this-page-banner
//= require modules/track-responses

window.addEventListener('DOMContentLoaded', function () {
  var error = document.getElementById('current-error')
  if (error) { error.focus() }
})
