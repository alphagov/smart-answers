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

/**
 * Provides support for a 'none' checkbox option.
 * When selected, all other options are deselected.
 * When other options are selected the 'none' option
 * is deselected.
 */
SmartAnswer.toggleCheckboxes = function() {
  var checkboxSel = ".govuk-checkboxes__input[type='checkbox']";
  var noneCheckboxSel = checkboxSel + "[value='none']";
  var $checkboxes = $(checkboxSel).not(noneCheckboxSel);
  var $noneCheckbox = $(noneCheckboxSel);
  var deselectOptions = function() {
    var $checkbox = this.value === 'none' ? $checkboxes : $noneCheckbox;
    if (this.checked) {
      $checkbox.prop('checked', false);
    }
  };
  $checkboxes.change(deselectOptions);
  $noneCheckbox.change(deselectOptions);
};

$(document).ready(SmartAnswer.toggleCheckboxes);
