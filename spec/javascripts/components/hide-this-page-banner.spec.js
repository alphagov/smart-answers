/* eslint-env jasmine */
/* global HideThisPageBanner */

describe('Hide this page banner component', function () {
  'use strict'

  var container
  var hideThisPageBannerElement
  var hideThisPageBannerModule

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = '<a class="app-c-hide-this-page-banner govuk-link" rel="nofollow noreferrer noopener" target="_blank" data-module="app-hide-this-page-banner" data-track-label="need-help-with" href="https://www.gov.uk/">Leave this site</a>'
    document.body.appendChild(container)
    hideThisPageBannerElement = document.querySelector('[data-module="app-hide-this-page-banner"]')
    hideThisPageBannerModule = new HideThisPageBanner(hideThisPageBannerElement)
    hideThisPageBannerModule.replaceCurrentPage = function () {}
    hideThisPageBannerModule.init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('opens a new page', function () {
    spyOn(hideThisPageBannerModule, 'openNewPage')
    hideThisPageBannerElement.click()
    expect(hideThisPageBannerModule.openNewPage).toHaveBeenCalledWith('https://www.gov.uk/', 'nofollow noreferrer noopener')
  })

  it('replaces the original page', function () {
    spyOn(hideThisPageBannerModule, 'replaceCurrentPage')
    hideThisPageBannerElement.click()
    expect(hideThisPageBannerModule.replaceCurrentPage).toHaveBeenCalledWith('https://www.gov.uk/')
  })
})
