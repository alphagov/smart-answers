 $(document).ready(function() {
  var formSelector = ".current form";
  initializeHistory();
  
  // events
  // get new questions on submit
  $(formSelector).live('submit', function(event) {
    $('input[type=submit]', this).attr('disabled', 'disabled');
    var form = $(this);
    reloadQuestions(form.attr('action'), form.serializeArray());
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
    if(event.state != null) {
			console.log(event)
			console.log(event.state)
      updateContent(event.state);
    }
    else if (urlFromHashtag()) {
      $.get(toJsonUrl(urlFromHashtag()), function(data) {
        updateContent(data['html_fragment']);
      });
    } else {
      return false;
    }
  }

  // helper functions
  function urlFromHashtag() {
    return window.location.hash.split('#')[1];
  }

  function toJsonUrl(url) {
    var parts = url.split('?');
    return parts[0] + ".json";
  }
  
  function fromJsonUrl(url) {
    return url.replace(/\.json$/, "");
  }
  
  // replace all the questions currently in the page with whatever is returned for given url
  function reloadQuestions(url, params) {
    $.get(toJsonUrl(url), params, function(data) {
      addToHistory(data);
      updateContent(data['html_fragment']);
    });
  };
    
  // manage the URL
  function addToHistory(data) {
    var url = data['url'];
    if (history && history.pushState) {
      // need the title from the json
      history.pushState(data, "Question", url);
    }
    else {
      window.location.hash = url;
      $(formSelector).attr("action", url);    
    };
  };

  // update the content (i.e. plonk in the html fragment)
  function updateContent(fragment){
    $('.smart_answer section').html(fragment);
		
  //  $('.next-question input[type=submit]').attr('disabled');
    // check if value or selected
    // if that
    // undisable
    // else
    // set event listener for change in value or selected
    //$(formSelector+' input[type=submit]').attr('disabled', 'disabled');
  };
  
  function initializeHistory(data) {
    // if hashed, means it's a non-pushstated URL that we need to generate the content for
    if (urlFromHashtag()) {
      reloadQuestions(urlFromHashtag(), "");
    }
    
    if (history && history.replaceState) {
      history.replaceState(
				$('.smart_answer section').html(), 
				"Question", 
				window.location.toString()
			);
    }
  }
});