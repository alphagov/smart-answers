function browserSupportsHtml5HistoryApi() {
  return !! (history && history.replaceState && history.pushState);
}

$(document).ready(function() {
  //_gaq.push(['_trackEvent', 'Citizen-Format-Smartanswer', 'Load']);
  if(browserSupportsHtml5HistoryApi()) {
    var formSelector = ".current form";
    initializeHistory();

    // events
    // get new questions on submit
    $(formSelector).live('submit', function(event) {
      $('input[type=submit]', this).attr('disabled', 'disabled');
      var form = $(this);
      var postData = form.serializeArray();
      reloadQuestions(form.attr('action'), postData);
      event.preventDefault();
      return false;
    });

    // we want to start over with whatever gets provided if someone clicks to change the answer
    $(".undo a").live('click', function() {
      reloadQuestions($(this).attr("href"), "");
      return false;
    });

    // manage next/back by tracking popstate event
    window.onpopstate = function (event) {
      if(event.state !== null) {
        updateContent(event.state['html_fragment']);
      } else {
        return false;
      }
    };
  }

  $('#current-error').focus();

  // helper functions
  function toJsonUrl(url) {
    var parts = url.split('?');
    var json_url = parts[0].replace(/\/$/, "") + ".json";
    if (parts[1]) {
      json_url += "?";
      json_url += parts[1];
    }
    return window.location.protocol + "//" + window.location.host + json_url;
  }

  function fromJsonUrl(url) {
    return url.replace(/\.json$/, "");
  }

  function redirectToNonAjax(url) {
    window.location = url;
  }

  // replace all the questions currently in the page with whatever is returned for given url
  function reloadQuestions(url, params) {
    var url = toJsonUrl(url);

    addLoading('<p>Loading next step&hellip;</p>');

    $.ajax(url, {
      type: 'GET',
      dataType:'json',
      data: params,
      timeout: 5000,
      error: function(jqXHR, textStatus, errorStr) {
        var paramStr = encodeURI($.param(params));
        redirectToNonAjax(url.replace('.json', '?' + paramStr));
      },
      success: function(data, textStatus, jqXHR) {
        addToHistory(data);
        updateContent(data['html_fragment']);
      }
    });
  }

  // manage the URL
  function addToHistory(data) {
    history.pushState(data, data['title'], data['url']);
  }

  // add an indicator of loading
  function addLoading(fragment){
    $('section .step.current')
      .addClass('loading')
      .html(fragment);
    $.event.trigger('smartanswerAnswer');
  };

  // update the content (i.e. plonk in the html fragment)
  function updateContent(fragment){
    $('.smart_answer section').html(fragment);
    $.event.trigger('smartanswerAnswer');
    if ($(".outcome").length !== 0) {
      $.event.trigger('smartanswerAnswer');
    }
  }

  function initializeHistory(data) {
    if (! browserSupportsHtml5HistoryApi() && window.location.pathname.match(/\/.*\//) ) {
      addToHistory({url: window.location.pathname});
    }

    data = {
      html_fragment: $('.smart_answer section').html(),
      title: "Question",
      url: window.location.toString()
    };
    history.replaceState(data, data['title'], data['url']);
  }

  var contentPosition = {
    latestQuestionTop : 0,
    latestQuestionIsOffScreen: function($latestQuestion) {
      var top_of_view = $(window).scrollTop();

      this.latestQuestionTop = $latestQuestion.offset().top;
      return (this.latestQuestionTop < top_of_view);
    },
    correctOffscreen: function() {
      $latestQuestion = $('.smart_answer .done-questions li.done:last-child');
      if (!$latestQuestion.length) {
        $latestQuestion = $('.smart_answer .step.current');
      }

      if(this.latestQuestionIsOffScreen($latestQuestion)) {
        $(window).scrollTop(this.latestQuestionTop);
      }
    },
    init: function() {
      var self = this; 
      $(document).bind('smartanswerAnswer', function() { self.correctOffscreen() });
    }
  }

  contentPosition.init();
});
