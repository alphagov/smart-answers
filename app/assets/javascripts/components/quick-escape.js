function QuickEscape ($module) {
  this.$module = $module
}

QuickEscape.prototype.init = function () {
  var $module = this.$module

  if (!$module) {
    return
  }
  $module.addEventListener('click', this.handleClick.bind(this))
  this.stickyEnhancement()
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

QuickEscape.prototype.stickyEnhancement = function() {
  var $wrapper = document.querySelector('.app-c-quick-escape')
  var isIE = (navigator.userAgent.indexOf("MSIE") != -1 ) || (!!document.documentMode == true)
  if (!isIE) return

  var offset = $wrapper.getBoundingClientRect();
  window.addEventListener('scroll', function() {
    if (window.pageYOffset > offset.top) {
      $wrapper.style.position = 'fixed';
    } else {
      $wrapper.style.position = 'relative';
    }
  });
}

var $quickEscape = document.querySelector('[data-module="app-quick-escape"]')
new QuickEscape($quickEscape).init()
