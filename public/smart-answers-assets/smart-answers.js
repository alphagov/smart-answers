function browserSupportsHtml5HistoryApi() {
  return !! (history && history.replaceState && history.pushState);
};

$(document).ready(function() {
	if(browserSupportsHtml5HistoryApi()){
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
		      updateContent(event.state['html_fragment']);
		    }
		    else if (urlFromHashtag()) {
		      $.get(toJsonUrl(urlFromHashtag()), function(data) {
		        updateContent(data['html_fragment']);
		      });
		    } else {
		      return false;
		    }
		  }
	}
  
  
  $('#current-error').focus();

  

  

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
		history.pushState(data, data['title'], data['url']);
  };

  // update the content (i.e. plonk in the html fragment)
  function updateContent(fragment){
    $('.smart_answer section').html(fragment);
  };
  
	

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
  };

});