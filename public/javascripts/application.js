// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

jQuery.fn.loadSurvey = function() {
	this.click(function() {
		alert('click');
		$.get(this.href, null, null, "script");
		return false;
	})
	return this;	
}

$(document).ready(function() {
	$("#test").loadSurvey();
})