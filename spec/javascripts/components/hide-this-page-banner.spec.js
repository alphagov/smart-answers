/* eslint-env jasmine */

describe('Hide this page banner component', function () {
  'use strict'

  var hideThisPageBannerElement
  var hideThisPageBannerModule

  beforeEach(function () {
    hideThisPageBannerElement = document.createElement('div')
    hideThisPageBannerElement.innerHTML = '<div class="app-c-hide-this-page-banner" data-module="app-hide-this-page-banner">' +
                                            '<div class="app-c-hide-this-page-banner__link-wrapper">' +
                                              '<a class="gem-c-button govuk-button govuk-button--warning" role="button" rel="nofollow noreferrer noopener" target="_blank" href="https://www.gov.uk/">Hide this page</a>' +
                                            '</div>' +
                                          '</div>'
    hideThisPageBannerModule = new GOVUK.Modules.HideThisPageBanner()
    hideThisPageBannerModule.replaceCurrentPage = function () {}
    hideThisPageBannerModule.start([hideThisPageBannerElement])
  })

  it('opens a new page', function () {
    spyOn(hideThisPageBannerModule, 'openNewPage')
    hideThisPageBannerElement.querySelector('.gem-c-button').click()
    expect(hideThisPageBannerModule.openNewPage).toHaveBeenCalledWith('https://www.gov.uk/', 'nofollow noreferrer noopener')
  })

  it('replaces the original page', function () {
    spyOn(hideThisPageBannerModule, 'replaceCurrentPage')
    hideThisPageBannerElement.querySelector('.gem-c-button').click()
    expect(hideThisPageBannerModule.replaceCurrentPage).toHaveBeenCalledWith('https://www.gov.uk/')
  })
})
