window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function TrackResponses ($module) {
    this.$module = $module

    this.init()
  }

  TrackResponses.prototype.init = function () {
    this.$module.addEventListener('submit', this.handleFormSubmit.bind(this))
  }

  TrackResponses.prototype.filterLabel = function () {
    return 'vaccination-status'
  }

  TrackResponses.prototype.filterResponse = function (questionKey, label) {
    var filteredLabel = label
    if (this.filterLabel() === questionKey) {
      filteredLabel = '[FILTERED]'
    }
    return { transport: 'beacon', label: filteredLabel }
  }

  TrackResponses.prototype.handleFormSubmit = function (event) {
    var submittedForm = event.target
    var questionKey = this.getQuestionKey(submittedForm)
    var responseLabels = this.getResponseLabels(submittedForm)

    for (var i = 0; i < responseLabels.length; i++) {
      var options = this.filterResponse(questionKey, responseLabels[i])
      GOVUK.analytics.trackEvent('response_submission', questionKey, options)
    }
  }

  TrackResponses.prototype.getQuestionKey = function (submittedForm) {
    return submittedForm.getAttribute('data-question-key')
  }

  TrackResponses.prototype.getResponseLabelsForInput = function (submittedForm) {
    var labels = []
    var checkedOptions = submittedForm.querySelectorAll('input:checked')

    if (checkedOptions.length) {
      for (var i = 0; i < checkedOptions.length; i++) {
        var checkedOption = checkedOptions[i]
        var checkedOptionId = checkedOption.getAttribute('id')
        var checkedOptionLabel = submittedForm.querySelectorAll('label[for="' + checkedOptionId + '"]')

        var eventLabel = checkedOptionLabel.length
          ? checkedOptionLabel[0].innerText.trim()
          : checkedOption.value

        labels.push(eventLabel)
      }
    } else {
      labels.push('no response')
    }

    return labels
  }

  TrackResponses.prototype.getResponseLabelsForSelect = function (submittedForm) {
    var labels = []
    var selectInputs = submittedForm.querySelectorAll('select')

    if (selectInputs.length) {
      for (var i = 0; i < selectInputs.length; i++) {
        var select = selectInputs[i]
        var value = select.value

        if (value) {
          var label = select.options[select.selectedIndex].innerHTML
          var eventLabel = label.length ? label : value
          labels.push(eventLabel)
        } else {
          labels.push('no response')
        }
      }
    }

    return labels
  }

  TrackResponses.prototype.getResponseLabels = function (submittedForm) {
    var responseLabels = []
    var questionType = submittedForm.getAttribute('data-type')

    switch (questionType) {
      case 'checkbox_question':
      case 'radio_question':
        responseLabels = this.getResponseLabelsForInput(submittedForm)
        break

      case 'country_select_question':
        responseLabels = this.getResponseLabelsForSelect(submittedForm)
        break

      default:
        break
    }

    return responseLabels
  }

  Modules.TrackResponses = TrackResponses
})(window.GOVUK.Modules)
