// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function dismissMessage(){
	$('.panel').removeClass('panel');
	$('#message.focus').css('left','101%');
	setTimeout(function(){
		$('#message.focus').html('');
		$('.active').removeClass('active');
	},230);
}

function messageSetup() {
	$('.project-select').select2({
		placeholder: "Select multiple projects...",
    	allowClear: true
	});
	$('.user-select').select2({
		placeholder: "Select individual recipients...",
    	allowClear: true
	});

	$('#dismiss-message').click(function(){
		dismissMessage();
	});

	$('#new-message #message-send').click(function(){
		$('.new_message').trigger('submit.rails')
	});
	$('#edit-message #message-send').click(function(){
		$('.edit_message').trigger('submit.rails')
	});
}