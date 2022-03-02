window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function MultipleCountries ($module) {
    this.$module = $module
    this.parentClass = '.js-country'
  }

  MultipleCountries.prototype.init = function () {
    this.countries = this.$module.querySelectorAll(this.parentClass)

    if (this.countries.length) {
      for (var i = 0; i < this.countries.length; i++) {
        var removeButton = this.createRemoveButton(this.countries[i])
        this.createRemoveButtonListener(removeButton)
      }
      this.hideSomeCountries()
      this.createAddButton()
    }
  }

  MultipleCountries.prototype.createRemoveButton = function (el) {
    var button = this.createButton('Remove <span class="govuk-visually-hidden">this country</span>', 'govuk-button--warning')
    el.appendChild(button)
    return button
  }

  MultipleCountries.prototype.createButton = function (text, classes) {
    classes = classes || ''
    var button = document.createElement('button')
    button.innerHTML = text
    button.setAttribute('class', 'gem-c-button govuk-button ' + classes)
    button.setAttribute('type', 'button')
    return button
  }

  MultipleCountries.prototype.createRemoveButtonListener = function (button) {
    button.addEventListener('click', function (e) {
      e.preventDefault()
      var button = e.target
      // hide the country and clear the input
      var parent = button.closest(this.parentClass)
      var input = parent.querySelector('input')
      parent.hidden = true
      input.value = ''
      // move the country to the end of the list ready to be shown again
      this.$module.appendChild(parent)
    }.bind(this))
  }

  MultipleCountries.prototype.hideSomeCountries = function () {
    // start at 1 because we should always show the zeroth country
    for (var i = 1; i < this.countries.length; i++) {
      var input = this.countries[i].querySelector('input')
      // only hide the country if it doesn't have a prefilled value
      if (!input.value) {
        this.countries[i].hidden = true
      }
    }
  }

  MultipleCountries.prototype.createAddButton = function () {
    var button = this.createButton('Add another country')
    this.$module.appendChild(button)
    // this.$module.parentNode.insertBefore(button, this.$module.nextSibling)
    button.addEventListener('click', function (e) {
      e.preventDefault()
      // find the first hidden country and show it
      var hidden = this.$module.querySelector(this.parentClass + '[hidden]')
      if (hidden) {
        hidden.hidden = false
      }
    }.bind(this))
  }

  Modules.MultipleCountries = MultipleCountries
})(window.GOVUK.Modules)
