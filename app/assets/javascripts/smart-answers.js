function browserSupportsHtml5HistoryApi() {
  return !! (history && history.replaceState && history.pushState);
}

$(document).ready(function() {
  if(browserSupportsHtml5HistoryApi()) {
    var formSelector = ".current form";

    initializeHistory();

    var getCurrentPosition = function () {
      var slugArray = document.URL.split('/');
      return slugArray.splice(3, slugArray.length).join('/');
    };

    // events
    // get new questions on submit
    $('#content').on('submit', formSelector, function(event) {
      $('input[type=submit]', this).attr('disabled', 'disabled');
      var form = $(this);
      var postData = form.serializeArray();
      reloadQuestions(form.attr('action'), postData);
      event.preventDefault();
      return false;
    });

    // Track when a user clicks on 'Start again' link
    $('#content').on('click', '.start-right', function() {
      GOVUK && GOVUK.analytics && GOVUK.analytics.trackEvent && GOVUK.analytics.trackEvent('MS_smart_answer', getCurrentPosition(), {label: 'Start again'});
      reloadQuestions($(this).attr('href'));
      return false;
    });

    // Track when a user clicks on a 'Change Answer' link
    $('#content').on('click', '.link-right a', function() {
      var href = $(this).attr('href');
      GOVUK && GOVUK.analytics && GOVUK.analytics.trackEvent && GOVUK.analytics.trackEvent('MS_smart_answer', href, {label: 'Change Answer'});
      reloadQuestions(href);
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

    addLoading('<p class="next-step">Loading next step&hellip;</p>');

    $.ajax(url, {
      type: 'GET',
      dataType:'json',
      data: params,
      timeout: 10000,
      error: function(jqXHR, textStatus, errorStr) {
        var paramStr = $.param(params);
        redirectToNonAjax(url.replace('.json', '?' + paramStr).replace('??', '?'));
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
    GOVUK && GOVUK.analytics && GOVUK.analytics.trackPageview && GOVUK.analytics.trackPageview(data['url']);
  }

  // add an indicator of loading
  function addLoading(fragment){
    $('#content .step.current')
      .addClass('loading')
      .find('form .next-question')
      .append(fragment);
    $.event.trigger('smartanswerAnswer');
  };

  // update the content (i.e. plonk in the html fragment)
  function updateContent(fragment){
    $('.smart_answer #js-replaceable').html(fragment);
    $.event.trigger('smartanswerAnswer');
    if ($(".outcome").length !== 0) {
      $.event.trigger('smartanswerOutcome');
    }
  }

  function initializeHistory(data) {
    if (! browserSupportsHtml5HistoryApi() && window.location.pathname.match(/\/.*\//) ) {
      addToHistory({url: window.location.pathname});
    }

    data = {
      html_fragment: $('.smart_answer #js-replaceable').html(),
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
        $latestQuestion = $('body');
      }

      if(this.latestQuestionIsOffScreen($latestQuestion)) {
        $(window).scrollTop(this.latestQuestionTop);
      }
    },
    init: function() {
      var self = this;
      $(document).bind('smartanswerAnswer', function() {
        self.correctOffscreen();
        $('.meta-wrapper').show();
      });
      // Show feedback form in outcomes
      $(document).bind('smartanswerOutcome', function() {
        $('.report-a-problem-container form #url').val(window.location.href);
        $('.meta-wrapper').show();
      });
    }
  };

  contentPosition.init();

});
