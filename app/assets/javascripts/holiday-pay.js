$(document).ready(function(){
  var formSelector = 'form#annual-leave';

  $(formSelector).submit( function(event) {
    var form = $(this);
    $('.error-notification').remove();
    $('input[type=submit]', this).attr('disabled', 'disabled');

    $.post('/calculate-your-holiday-entitlement.json', form.serializeArray(), function(data){
      if (data.entitlement && data.entitlement_period) {
        $('#holidays-answer').show().find('.result').html(data.entitlement + ' ' + data.entitlement_period);
      } else {
        $('<div class="error-notification"/>').text(data.errors.join('<br />')).prependTo(form);
        $('#holidays-answer').hide();
      }
      $('input[type=submit]', form).removeAttr('disabled');
    });

    event.preventDefault();
    return false;
  });
});