$(document).ready(function() {
	var formSelector = ".current form";
	
	// if hashed, means it's a non-pushstated URL that we need to generate the content for
	if(window.location.hash){		
		var hash = window.location.hash,
			hash = hash.split('#')[1];
		
		reloadQuestions(hash);	
	};

	// events
	// get new questions on submit
  $(formSelector).live('submit', function(event) {
		$('input[type=submit]', this).attr('disabled', 'disabled');
    var form = $(this);
    getNextQuestion(form)
    event.preventDefault();
    return false;
  });

	// we want to start over with whatever gets provided if someone clicks to change the answer
	$(".undo a").live('click', function(){
		reloadQuestions($(this).attr("href"));
		return false;
	});

	// manage next/back by tracking popstate event
	window.onpopstate = function (event) {
		var url = window.location;
		if(event.state != null){
			url = event.state.url;
		}
	  $.get(url+"?format=json", function(data) {
      updateContent(data['html_fragment']);
    }, 'json');
	}

	// helper functions
	// replace all the questions currently in the page with whatever is returned for given url
	function reloadQuestions(url){
		$.get(url+"?format=json", function(data) {
      updateContent(data['html_fragment']);
      updateURL(data, data['url']);
    }, 'json');
	};
	
	// send the answer to last Q and get next question set
	function getNextQuestion(form){
		var url = form.attr('action');
		$.get(url+"?format=json", form.serializeArray(), function(data) {
      updateContent(data['html_fragment']);
      updateURL(data, data['url']);
    }, 'json');
	};
	
	// manage the URL
	function updateURL(data, url){
		if(history && history.pushState){
			// need the title from the json
			history.pushState(data, "Question", url);
		}
		else{
			window.location.hash = url;
			$(formSelector).attr("action", url);		
		};
	};

	// update the content (i.e. plonk in the html fragment)
	function updateContent(fragment){
		$('.smart_answer section').html(fragment);
	//	$('.next-question input[type=submit]').attr('disabled');
		// check if value or selected
		// if that
		// undisable
		// else
		// set event listener for change in value or selected
		//$(formSelector+' input[type=submit]').attr('disabled', 'disabled');
	};
	

	

});