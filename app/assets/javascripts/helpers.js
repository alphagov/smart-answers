var SmartAnswer = SmartAnswer || {}
SmartAnswer.isStartPage = function (slug) { // Used mostly during A/B testing
  return window.location.pathname.split('/').join('') == slug
}

function trackInternalLinks (rootSelector) {
  rootSelector = rootSelector || 'body'
  var currentHost = document.location.protocol + '//' + document.location.hostname
  var internalLinkSelector = 'a[href^="' + currentHost + '"], a[href^="/"]'

  $(rootSelector).find(internalLinkSelector).on('click', trackClickEvent)

  function trackClickEvent (evt) {
    var $link = getLinkFromEvent(evt)
    var options = { transport: 'beacon' }
    var href = $link.attr('href')
    var linkText = $.trim($link.text())

    if (linkText) {
      options.label = linkText
    }

    GOVUK.analytics.trackEvent('Internal Link Clicked', href, options)
  };

  function getLinkFromEvent (evt) {
    var $target = $(evt.target)

    if (!$target.is('a')) {
      $target = $target.parents('a')
    }

    return $target
  };
};
