/* eslint-env jasmine */
/* global GOVUK */

describe('Track responses', function () {
  GOVUK.analytics = GOVUK.analytics || {}
  GOVUK.analytics.trackEvent = function () {}

  describe('checkbox question', function () {
    var tracker, form

    var createForm = function () {
      var element = document.createElement('form')
      element.setAttribute('onsubmit', 'event.preventDefault()')
      element.setAttribute('data-module', 'track-responses')
      element.setAttribute('data-type', 'checkbox_question')
      element.setAttribute('data-question-key', 'question-key')
      element.setAttribute('method', 'post')

      var fieldset = document.createElement('fieldset')

      var checkboxes = [
        { label: 'Construction label', value: 'construction' },
        { label: 'Accommodation label', value: 'accommodation' },
        { value: 'furniture' }
      ]

      for (var index = 0; index < checkboxes.length; index++) {
        var checkbox = checkboxes[index]
        var id = 'checkbox-' + index
        var checkboxWrapper = document.createElement('div')
        var input = document.createElement('input')
        input.type = 'checkbox'
        input.id = id
        input.name = 'checkbox_question[]'
        input.value = checkbox.value

        checkboxWrapper.appendChild(input)

        if (checkbox.label) {
          var label = document.createElement('label')
          label.setAttribute('for', id)
          label.innerText = checkbox.label
          checkboxWrapper.appendChild(label)
        }

        fieldset.appendChild(checkboxWrapper)
      }

      element.appendChild(fieldset)

      var button = document.createElement('button')
      button.type = 'submit'

      element.appendChild(button)

      return element
    }

    beforeEach(function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      form = createForm()

      tracker = new GOVUK.Modules.TrackResponses(form)
      tracker.init()
    })

    afterEach(function () {
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks checked checkboxes when clicking submit', function () {
      form.querySelector('input[value="accommodation"]').click()
      form.querySelector('input[value="construction"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'Construction label' }
      )
      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('filters out sensitive responses', function () {
      spyOn(tracker, 'filterLabel').and.returnValue('question-key')

      form.querySelector('input[value="accommodation"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: '[FILTERED]' }
      )
    })

    it('track events sends value of checkbox when no label is set', function () {
      form.querySelector('input[value="furniture"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'furniture' }
      )
    })

    it('track event triggered when no response is made', function () {
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'no response' }
      )
    })
  })

  describe('radio question', function () {
    var tracker, form

    var createForm = function () {
      var element = document.createElement('form')
      element.setAttribute('onsubmit', 'event.preventDefault()')
      element.setAttribute('data-module', 'track-responses')
      element.setAttribute('data-type', 'radio_question')
      element.setAttribute('data-question-key', 'question-key')
      element.setAttribute('method', 'post')

      var fieldset = document.createElement('fieldset')

      var radios = [
        { label: 'Construction label', value: 'construction' },
        { label: 'Accommodation label', value: 'accommodation' },
        { label: 'Furniture label', value: 'furniture' }
      ]

      for (var index = 0; index < radios.length; index++) {
        var radio = radios[index]
        var id = 'radio-' + index
        var radioWrapper = document.createElement('div')
        var input = document.createElement('input')
        input.type = 'radio'
        input.id = id
        input.name = 'radio_question'
        input.value = radio.value

        radioWrapper.appendChild(input)

        if (radio.label) {
          var label = document.createElement('label')
          label.setAttribute('for', id)
          label.innerText = radio.label
          radioWrapper.appendChild(label)
        }

        fieldset.appendChild(radioWrapper)
      }

      element.appendChild(fieldset)

      var button = document.createElement('button')
      button.type = 'submit'

      element.appendChild(button)

      return element
    }

    beforeEach(function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      form = createForm()

      tracker = new GOVUK.Modules.TrackResponses(form)
      tracker.init()
    })

    afterEach(function () {
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks selected option when clicking submit', function () {
      form.querySelector('input[value="accommodation"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('filters out sensitive responses', function () {
      spyOn(tracker, 'filterLabel').and.returnValue('question-key')

      form.querySelector('input[value="accommodation"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: '[FILTERED]' }
      )
    })

    it('track event triggered when no response is made', function () {
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'no response' }
      )
    })
  })

  describe('select question', function () {
    var tracker, form

    var createForm = function () {
      var element = document.createElement('form')
      element.setAttribute('onsubmit', 'event.preventDefault()')
      element.setAttribute('data-module', 'track-responses')
      element.setAttribute('data-type', 'country_select_question')
      element.setAttribute('data-question-key', 'question-key')
      element.setAttribute('method', 'post')

      var select = document.createElement('select')
      select.name = 'select_question'

      var selectOptions = [
        { label: 'Select option', value: '' },
        { label: 'Construction label', value: 'construction' },
        { label: 'Accommodation label', value: 'accommodation' },
        { label: 'Furniture label', value: 'furniture' }
      ]

      for (var index = 0; index < selectOptions.length; index++) {
        var opt = selectOptions[index]
        var option = document.createElement('option')
        option.value = opt.value
        option.innerText = opt.label

        select.appendChild(option)
      }

      element.appendChild(select)

      var button = document.createElement('button')
      button.type = 'submit'

      element.appendChild(button)

      return element
    }

    beforeEach(function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      form = createForm()

      tracker = new GOVUK.Modules.TrackResponses(form)
      tracker.init()
    })

    afterEach(function () {
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks selected option when clicking submit', function () {
      form.querySelector('select[name="select_question"]').value = 'accommodation'
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('filters out sensitive responses', function () {
      spyOn(tracker, 'filterLabel').and.returnValue('question-key')

      form.querySelector('select[name="select_question"]').value = 'accommodation'
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: '[FILTERED]' }
      )
    })

    it('track event triggered when no response is made', function () {
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'response_submission', 'question-key', { transport: 'beacon', label: 'no response' }
      )
    })
  })
})
