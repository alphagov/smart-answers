/* eslint-env jasmine */
/* global GOVUK */

describe('Track results', function () {
  GOVUK.analytics = GOVUK.analytics || {}
  GOVUK.analytics.trackEvent = function () {}

  describe('checkbox question', function () {
    var tracker, container, element

    beforeEach(function () {
      container = document.createElement('div')
      container.innerHTML = '<div data-module="track-results" data-flow-name="My Flow">' +
                              '<a class="govuk-link" href="/internal-link">Internal link</a>' +
                              '<a class="govuk-link" href="https://github.com">External link</a>' +
                            '</div>'
      document.body.appendChild(container)
      element = document.querySelector('[data-module="track-results"]')
    })

    afterEach(function () {
      document.body.removeChild(container)
      GOVUK.analytics.trackEvent.calls.reset()
    })

    it('tracks completed flow', function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      tracker = new GOVUK.Modules.TrackResults(element)
      tracker.init()

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'Smart Answer', 'Completed', { label: 'My Flow', nonInteraction: true, page: document.location.pathname }
      )
    })

    it('tracks an internal result link', function () {
      var internalLink = container.querySelectorAll('a')[0]
      tracker = new GOVUK.Modules.TrackResults(element)
      tracker.init()

      spyOn(GOVUK.analytics, 'trackEvent')

      internalLink.dispatchEvent(new window.Event('click'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'Internal Link Clicked', '/internal-link', { transport: 'beacon', label: 'Internal link' }
      )
    })

    it('does not track an external result link', function () {
      var externalLink = container.querySelectorAll('a')[1]
      tracker = new GOVUK.Modules.TrackResults(element)
      tracker.init()

      spyOn(GOVUK.analytics, 'trackEvent')

      externalLink.dispatchEvent(new window.Event('click'))

      expect(GOVUK.analytics.trackEvent).not.toHaveBeenCalled()
    })
  })
})
