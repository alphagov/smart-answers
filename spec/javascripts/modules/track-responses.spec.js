/* eslint-env jasmine */
/* global GOVUK */

describe('Track responses', function () {
  GOVUK.analytics = GOVUK.analytics || {}
  GOVUK.analytics.trackEvent = function () {}

  describe('checkbox question', function() {
    var tracker, form

    var createForm = function() {
      var element = document.createElement('form');
      element.setAttribute('onsubmit', 'event.preventDefault()')
      element.setAttribute('data-module', 'track-responses')
      element.setAttribute('data-type', 'checkbox_question')
      element.setAttribute('data-question-key', 'question-key')
      element.setAttribute('method', 'post')

      var fieldset = document.createElement('fieldset');

      var checkboxes = [
        {label: "Construction label", value: "construction"},
        {label: "Accommodation label", value: "accommodation"},
        {value: "furniture"}
      ]

      checkboxes.forEach(function(checkbox, index){
        var id = 'checkbox-' + index
        var checkbox_wrapper = document.createElement('div')
        var input = document.createElement('input')
        input.type = 'checkbox'
        input.id = id
        input.name = 'checkbox_question[]'
        input.value = checkbox.value

        checkbox_wrapper.appendChild(input)

        if (checkbox.label) {
          var label = document.createElement('label')
          label.setAttribute('for', id)
          label.innerText = checkbox.label
          checkbox_wrapper.appendChild(label)
        }

        fieldset.appendChild(checkbox_wrapper)
      })

      element.appendChild(fieldset)

      var button = document.createElement('button')
      button.type = 'submit'

      element.appendChild(button)

      return element
    }

    beforeEach(function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      form = createForm()

      tracker = new GOVUK.Modules.TrackResponses()
      tracker.start([form])
    })

    afterEach(function () {
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks checked checkboxes when clicking submit', function () {
      form.querySelector('input[value="accommodation"]').click()
      form.querySelector('input[value="construction"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'Construction label' }
      )
      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('track events sends value of checkbox when no label is set', function () {
      form.querySelector('input[value="furniture"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'furniture' }
      )
    })

    it('track event triggered when no response is made', function () {
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'no response' }
      )
    })
  })

  describe('radio question', function() {
    var tracker, form

    var createForm = function() {
      var element = document.createElement('form');
      element.setAttribute('onsubmit', 'event.preventDefault()')
      element.setAttribute('data-module', 'track-responses')
      element.setAttribute('data-type', 'radio_question')
      element.setAttribute('data-question-key', 'question-key')
      element.setAttribute('method', 'post')

      var fieldset = document.createElement('fieldset');

      var radios = [
        {label: "Construction label", value: "construction"},
        {label: "Accommodation label", value: "accommodation"},
        {label: "Furniture label", value: "furniture"}
      ]

      radios.forEach(function(radio, index){
        var id = 'radio-' + index
        var radio_wrapper = document.createElement('div')
        var input = document.createElement('input')
        input.type = 'radio'
        input.id = id
        input.name = 'radio_question'
        input.value = radio.value

        radio_wrapper.appendChild(input)

        if (radio.label) {
          var label = document.createElement('label')
          label.setAttribute('for', id)
          label.innerText = radio.label
          radio_wrapper.appendChild(label)
        }

        fieldset.appendChild(radio_wrapper)
      })

      element.appendChild(fieldset)

      var button = document.createElement('button')
      button.type = 'submit'

      element.appendChild(button)

      return element
    }

    beforeEach(function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      form = createForm()

      tracker = new GOVUK.Modules.TrackResponses()
      tracker.start([form])
    })

    afterEach(function () {
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks selected option when clicking submit', function () {
      form.querySelector('input[value="accommodation"]').click()
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('track event triggered when no response is made', function () {
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'no response' }
      )
    })
  })

  describe('select question', function() {
    var tracker, form

    var createForm = function() {
      var element = document.createElement('form');
      element.setAttribute('onsubmit', 'event.preventDefault()')
      element.setAttribute('data-module', 'track-responses')
      element.setAttribute('data-type', 'country_select_question')
      element.setAttribute('data-question-key', 'question-key')
      element.setAttribute('method', 'post')

      var select = document.createElement('select');
      select.name = 'select_question'

      var selectOptions = [
        {label: "Select option", value: ""},
        {label: "Construction label", value: "construction"},
        {label: "Accommodation label", value: "accommodation"},
        {label: "Furniture label", value: "furniture"}
      ]

      selectOptions.forEach(function(opt, index){
        var option = document.createElement('option')
        option.value = opt.value
        option.innerText = opt.label

        select.appendChild(option)
      })

      element.appendChild(select)

      var button = document.createElement('button')
      button.type = 'submit'

      element.appendChild(button)

      return element
    }

    beforeEach(function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      form = createForm()

      tracker = new GOVUK.Modules.TrackResponses()
      tracker.start([form])
    })

    afterEach(function () {
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks selected option when clicking submit', function () {
      form.querySelector('select[name="select_question"]').value = "accommodation"
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('track event triggered when no response is made', function () {
      form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'question_answer', 'question-key', { transport: 'beacon', label: 'no response' }
      )
    })
  })
})
