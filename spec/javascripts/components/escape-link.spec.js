/* eslint-env jasmine */
/* global EscapeLink */

describe('Escape link component', function () {
  'use strict'

  var container
  var escapeLinkElement
  var escapeLinkModule

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = '<a class="app-c-escape-link govuk-link" rel="nofollow noreferrer noopener" target="_blank" data-module="app-quick-escape" data-track-label="need-help-with" href="https://www.gov.uk/">Leave this site</a>'
    document.body.appendChild(container)
    escapeLinkElement = document.querySelector('[data-module="app-quick-escape"]')
    escapeLinkModule = new EscapeLink(escapeLinkElement)
    escapeLinkModule.replaceCurrentPage = function () {}
    escapeLinkModule.init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('opens a new page', function () {
    spyOn(escapeLinkModule, 'openNewPage')
    escapeLinkElement.click()
    expect(escapeLinkModule.openNewPage).toHaveBeenCalledWith('https://www.gov.uk/', 'nofollow noreferrer noopener')
  })

  it('replaces the original page', function () {
    spyOn(escapeLinkModule, 'replaceCurrentPage')
    escapeLinkElement.click()
    expect(escapeLinkModule.replaceCurrentPage).toHaveBeenCalledWith('https://www.gov.uk/')
  })
})
