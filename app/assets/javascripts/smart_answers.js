$(function() {
  $('.steps .current form').live('submit', function(event) {
    var $form = $(this);
    $.get($form.attr('action'), $form.serializeArray(), function(data, textStatus, jqXHR) {
      $('.content').html(data['html_fragment']);
      window.history.pushState(data, "???", data['url']);
    }, 'json');
    event.preventDefault();
    return false;
  })
});