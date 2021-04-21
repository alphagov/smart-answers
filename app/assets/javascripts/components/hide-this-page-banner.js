function HideThisPageBanner ($module) {
  this.$module = $module
}

HideThisPageBanner.prototype.init = function () {
  var $module = this.$module

  if (!$module) return

  $module
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

var $hideThisPageBanner = document.querySelector('[data-module="app-hide-this-page-banner"]')
new HideThisPageBanner($hideThisPageBanner).init()
