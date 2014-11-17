// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function messageSetup() {
	$('.project-select').select2({
		placeholder: "Select multiple projects...",
    	allowClear: true
	});
	$('.user-select').select2({
		placeholder: "Select individual recipients...",
    	allowClear: true
	});
}