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

  $('*[data-debug-template-path]').each(function () {
    var element = $(this);
    var path = element.data('debug-template-path');
    var filename = filenameFrom(path);
    var url = githubUrlFrom(path);
    var anchor = $('<a>Template on GitHub</a>').attr('href', url).attr('style', 'color: deeppink;').attr('title', filename);
    element.prepend(anchor);
    element.attr('style', 'border: 3px solid deeppink; padding: 10px; margin: 3px');
    element.removeAttr('data-debug-template-path');
  });

  $('*[data-debug-partial-template-path]').each(function () {
    var element = $(this);
    var path = element.data('debug-partial-template-path');
    var filename = filenameFrom(path);
    var url = githubUrlFrom(path);
    var anchor = $('<a>Partial template on GitHub</a>').attr('href', url).attr('style', 'color: hotpink;').attr('title', filename);
    element.prepend(anchor);
    element.attr('style', 'border: 3px dotted hotpink; padding: 10px; margin: 3px');
    element.removeAttr('data-debug-partial-template-path');
  });
}
