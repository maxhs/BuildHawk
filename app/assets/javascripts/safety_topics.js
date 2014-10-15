// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function readMoreLess() {
	$('.read-more').click(function(){
		var clicked = $(this);
		var $parent = $(this).parent();
	    if($parent.find('.full').css('display') == 'none') {
	        clicked.text("Read Less");
	        $parent.find('.truncated').hide();
	        $parent.find('.full').show();
	    } else {
	        clicked.text("Read More");
	        $parent.find('.truncated').show();
	        $parent.find('.full').hide();
	    }
	});
}