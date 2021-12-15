/* global accessibleAutocomplete */
//= require accessible-autocomplete/dist/accessible-autocomplete.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function Autocomplete ($module) {
    this.$module = $module
    this.$input = this.$module.querySelector('input')
    this.$datalist = this.$module.querySelector('datalist')
    this.sources = []
  }

  Autocomplete.prototype.init = function () {
    if (!this.$datalist) {
      return
    }

    this.getDataListContents()

    var configOptions = {
      element: this.$module,
      id: this.$input.id,
      defaultValue: this.$input.value,
      source: this.sources
    }

    accessibleAutocomplete(configOptions) // eslint-disable-line new-cap
    this.copyInputAttributes()
  }

  Autocomplete.prototype.getDataListContents = function () {
    var options = this.$datalist.querySelectorAll('option')
    for (var i = 0; i < options.length; i++) {
      this.sources.push(options[i].getAttribute('value'))
    }
  }

  // the name attribute isn't copied by the accessible autocomplete code
  Autocomplete.prototype.copyInputAttributes = function () {
    var name = this.$input.getAttribute('name')
    var autoCompleteInput = this.$module.querySelector('.autocomplete__input')
    autoCompleteInput.setAttribute('name', name)
    this.$input.parentNode.removeChild(this.$input)
  }

  Modules.Autocomplete = Autocomplete
})(window.GOVUK.Modules)
