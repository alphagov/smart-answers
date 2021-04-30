window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function HideThisPageBanner () { }

  HideThisPageBanner.prototype.start = function ($module) {
    this.$module = $module[0]

    this.$module
      .querySelector('.gem-c-button')
      .addEventListener('click', this.handleClick.bind(this))
  }

  HideThisPageBanner.prototype.handleClick = function (event) {
    event.preventDefault()

    var url = event.target.getAttribute('href')
    var rel = event.target.getAttribute('rel')

    this.openNewPage(url, rel)
    this.replaceCurrentPage(url)
  }

  HideThisPageBanner.prototype.openNewPage = function (url, rel) {
    var newWindow = window.open(url, rel)
    newWindow.opener = null
  }

  HideThisPageBanner.prototype.replaceCurrentPage = function (url) {
    window.location.replace(url)
  }

  Modules.HideThisPageBanner = HideThisPageBanner
})(window.GOVUK.Modules)
