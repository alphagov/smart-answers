var SmartAnswer = SmartAnswer || {};
SmartAnswer.isStartPage = function(slug) { // Used mostly during A/B testing
  return window.location.pathname.split("/").join("") == slug;
}

function linkToTemplatesOnGithub() {
  $('*[data-debug-template-path]').each(function() {
    var element = $(this);
    var path = element.data('debug-template-path');
    var filename = path.split('/').pop();
    var host = 'https://github.com';
    var organisation = 'alphagov';
    var repository = 'smart-answers'
    var branch = 'deployed-to-production';
    var url = [host, organisation, repository, 'blob', branch, path].join('/');
    var anchor = $('<a>Template on GitHub</a>').attr('href', url).attr('style', 'color: deeppink;').attr('title', filename);
    element.prepend(anchor);
    element.attr('style', 'border: 3px solid deeppink; padding: 10px; margin: 3px');
    element.removeAttr('data-debug-template-path');
  });
};

function trackInternalLinks (rootSelector) {
  rootSelector = rootSelector || 'body';
  var currentHost = document.location.protocol + '//' + document.location.hostname;
  var internalLinkSelector = 'a[href^="' + currentHost + '"], a[href^="/"]';

  $(rootSelector).find(internalLinkSelector).on('click', trackClickEvent);

  function trackClickEvent (evt) {
    var $link = getLinkFromEvent(evt);
    var options = {transport: 'beacon'};
    var href = $link.attr('href');
    var linkText = $.trim($link.text());

    if (linkText) {
      options.label = linkText;
    }

    GOVUK.analytics.trackEvent('Internal Link Clicked', href, options);
  };

  function getLinkFromEvent (evt) {
    var $target = $(evt.target);

    if (!$target.is('a')) {
      $target = $target.parents('a');
    }

    return $target;
  };
};
