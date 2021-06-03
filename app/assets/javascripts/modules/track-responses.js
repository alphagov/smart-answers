window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function TrackResponses ($module) {
    this.$module = $module
  }

  TrackResponses.prototype.init = function () {
    this.$module.addEventListener('submit', this.handleFormSubmit.bind(this))
  }

  TrackResponses.prototype.handleFormSubmit = function (event) {
    var submittedForm = event.target
    var questionHeading = this.getQuestionHeading(submittedForm)
    var questionKey = this.getQuestionKey(submittedForm)
    var responseLabels = this.getResponseLabels(submittedForm)

    responseLabels.forEach(function (label) {
      var options = { transport: 'beacon', label: label }
      GOVUK.analytics.trackEvent('question_answer', questionHeading, options)
      GOVUK.analytics.trackEvent('response_submission', questionKey, options)
    })
  }

  TrackResponses.prototype.getQuestionHeading = function (submittedForm) {
    return submittedForm.getAttribute('data-question-text')
  }

  TrackResponses.prototype.getQuestionKey = function (submittedForm) {
    return submittedForm.getAttribute('data-question-key')
  }

  TrackResponses.prototype.getResponseLabelsForRadio = function (submittedForm) {
    var labels = []
    var checkedOptions = submittedForm.querySelectorAll('input:checked')

    if (checkedOptions.length) {
      checkedOptions.forEach(function (checkedOption) {
        var checkedOptionId = checkedOption.getAttribute('id')
        var checkedOptionLabel = submittedForm.querySelectorAll('label[for="' + checkedOptionId + '"]')

        var eventLabel = checkedOptionLabel.length
          ? checkedOptionLabel[0].innerText.trim()
          : checkedOption.value

        labels.push(eventLabel)
      })
    } else {
      labels.push('no response')
    }

    return labels
  }

  TrackResponses.prototype.getResponseLabelsForSelectOption = function (submittedForm) {
    var labels = []
    var selectInputs = submittedForm.querySelectorAll('select')

    if (selectInputs.length) {
      selectInputs.forEach(function (select) {
        var value = select.value

        if (value) {
          var label = select.options[select.selectedIndex].innerHTML
          var eventLabel = label.length ? label : value
          labels.push(eventLabel)
        } else {
          labels.push('no response')
        }
      })
    }

    return labels
  }

  TrackResponses.prototype.getResponseLabels = function (submittedForm) {
    var responseLabels = []
    var questionType = submittedForm.getAttribute('data-type')

    switch (questionType) {
      case 'checkbox_question':
      case 'radio_question':
        responseLabels = this.getResponseLabelsForRadio(submittedForm)
        break

      case 'country_select_question':
        responseLabels = this.getResponseLabelsForSelectOption(submittedForm)
        break

      default:
        break
    }

    return responseLabels
  }

  Modules.TrackResponses = TrackResponses
})(window.GOVUK.Modules)
