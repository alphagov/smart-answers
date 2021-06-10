/* eslint-env jasmine */

describe('Hide this page banner component', function () {
  'use strict'

  var container
  var hideThisPageBannerElement
  var hideThisPageBannerButton
  var hideThisPageBannerModule

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML = '<div class="app-c-hide-this-page-banner" data-module="app-hide-this-page-banner">' +
                            '<div class="app-c-hide-this-page-banner__link-wrapper">' +
                              '<a class="gem-c-button govuk-button govuk-button--warning" role="button" rel="nofollow noreferrer noopener" target="_blank" href="https://www.gov.uk/">Hide this page</a>' +
                            '</div>' +
                          '</div>'

    document.body.appendChild(container)
    hideThisPageBannerElement = document.querySelector('[data-module="app-hide-this-page-banner"]')
    hideThisPageBannerButton = hideThisPageBannerElement.querySelector('.gem-c-button')
    hideThisPageBannerModule = new GOVUK.Modules.HideThisPageBanner(hideThisPageBannerElement)
    hideThisPageBannerModule.init()

    spyOn(window, 'open').and.returnValue({})
    // stub replaceCurrentPage as window.location cannot be stubbed
    spyOn(hideThisPageBannerModule, 'replaceCurrentPage')
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  it('opens a new page', function () {
    hideThisPageBannerButton.dispatchEvent(new window.Event('click'))
    expect(window.open).toHaveBeenCalledWith('https://www.gov.uk/', 'nofollow noreferrer noopener')
  })

  it('replaces the original page', function () {
    hideThisPageBannerButton.dispatchEvent(new window.Event('click'))
    expect(hideThisPageBannerModule.replaceCurrentPage).toHaveBeenCalledWith('https://www.gov.uk/')
  })
})
