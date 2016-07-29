var SmartAnswer = SmartAnswer || {};
SmartAnswer.isStartPage = function(slug) { // Used mostly during A/B testing
  return window.location.pathname.split("/").join("") == slug;
};

function linkToTemplatesOnGithub() {
  function filenameFrom(path) {
    return path.split('/').pop();
  }

  function githubUrlFrom(path) {
    var host = 'https://github.com';
    var organisation = 'alphagov';
    var repository = 'smart-answers';
    var branch = 'deployed-to-production';
    return [host, organisation, repository, 'blob', branch, path].join('/');
  }

  function annotateContent(options) {
    $('*[data-' + options.dataAttribute + ']').each(function () {
      var element = $(this);
      var path = element.data(options.dataAttribute);
      var filename = filenameFrom(path);
      var url = githubUrlFrom(path);
      var anchor = $('<a>' + options.anchorText + '</a>').attr('href', url).attr('style', 'color: ' + options.anchorColor + ';').attr('title', filename);
      element.prepend(anchor);
      element.attr('style', options.borderStyle);
      element.removeAttr('data-' + options.dataAttribute);
    });
  }

  annotateContent({
    dataAttribute: 'debug-template-path',
    anchorText: 'Template on GitHub',
    anchorColor: 'deeppink',
    borderStyle: 'border: 3px solid deeppink; padding: 10px; margin: 3px'
  });

  annotateContent({
    dataAttribute: 'debug-partial-template-path',
    anchorText: 'Partial template on GitHub',
    anchorColor: 'hotpink',
    borderStyle: 'border: 3px dotted hotpink; padding: 10px; margin: 3px'
  });
}
