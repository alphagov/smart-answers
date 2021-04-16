function QuickEscape ($module) {
  this.$module = $module
}

QuickEscape.prototype.init = function () {
  var $module = this.$module

  if (!$module) {
    return
  }
  $module.addEventListener('click', this.handleClick.bind(this))
}

QuickEscape.prototype.handleClick = function (event) {
  event.preventDefault()

  var url = event.target.getAttribute('href')
  var rel = event.target.getAttribute('rel')

  this.openNewPage(url, rel)
  this.replaceCurrentPage(url)
}

QuickEscape.prototype.openNewPage = function (url, rel) {
  var newWindow = window.open(url, rel)
  newWindow.opener = null
}

QuickEscape.prototype.replaceCurrentPage = function (url) {
  window.location.replace(url)
}

var $quickEscape = document.querySelector('[data-module="app-quick-escape"]')
new QuickEscape($quickEscape).init()
