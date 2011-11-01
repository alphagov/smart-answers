$(document).ready(function() {
	var hasPushState = false,
		formSelector = ".steps .current form";
	
	if(history && history.pushState){
		hasPushState = false;
	};

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


	// helper functions
	// replace all the questions currently in the page with whatever is returned for given url
	function reloadQuestions(url){
		$.get(url, function(data) {
      updateContent(data['html_fragment']);
      updateURL(data, data['url']);
    }, 'json');
	};
	
	// send the answer to last Q and get next question set
	function getNextQuestion(form){
		$.get(form.attr('action'), form.serializeArray(), function(data) {
      updateContent(data['html_fragment']);
      updateURL(data, data['url']);
    }, 'json');
	};
	
	
	// manage the URL
	function updateURL(data, url){
		if(hasPushState){
			history.pushState(data, "???", url);
		}
		else{
			window.location.hash = url;
			$(formSelector).attr("action", url);		
		};
	};

	// update the content (i.e. plonk in the html fragment)
	function updateContent(fragment){
		$('section').html(fragment);
	};
	
	
/*	window.onpopstate = function (event) {
	  // see what is available in the event object
	  console.log(event)
	}*/
	

});