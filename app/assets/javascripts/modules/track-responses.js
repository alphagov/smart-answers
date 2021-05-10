window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict'

  GOVUK.Modules.TrackResponses = function () {
    this.start = function (element) {
      track(element[0])
    }

    function getQuestionHeading (submittedForm) {
      return submittedForm.getAttribute('data-question-text')
    }

    function getQuestionKey (submittedForm) {
      return submittedForm.getAttribute('data-question-key')
    }

    function getResponseLabelsForRadio (submittedForm) {
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

    function getResponseLabelsForSelectOption (submittedForm) {
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

    function getResponseLabels (submittedForm) {
      var responseLabels = []
      var questionType = submittedForm.getAttribute('data-type')

      switch (questionType) {
        case 'checkbox_question':
        case 'radio_question':
          responseLabels = getResponseLabelsForRadio(submittedForm)
          break

        case 'country_select_question':
          responseLabels = getResponseLabelsForSelectOption(submittedForm)
          break

        default:
          break
      }

      return responseLabels
    }

    function track (element) {
      element.addEventListener('submit', function (event) {
        var submittedForm = event.target
        var questionHeading = getQuestionHeading(submittedForm)
        var questionKey = getQuestionKey(submittedForm)
        var responseLabels = getResponseLabels(submittedForm)

        responseLabels.forEach(function (label) {
          var options = { transport: 'beacon', label: label }
          GOVUK.analytics.trackEvent('question_answer', questionHeading, options)
          GOVUK.analytics.trackEvent('response_submission', questionKey, options)
        })
      })
    }
  }
})(window, window.GOVUK)
