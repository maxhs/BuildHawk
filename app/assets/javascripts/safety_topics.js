// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function readMoreLess() {
	$('.read-more').click(function(){
		var clicked = $(this);
		var $parent = $(this).parent();
		var $hidden = $parent.find($('.hiddenText'));
	    if($hidden.css('display') === 'none') {
	    	$parent.find('.ellipsis').replaceWith($hidden);
	        $hidden.show(100).css('display','inline');
	        clicked.text("Read Less");
	    } else {
	        clicked.text("Read More");
	        $hidden.before('<span class="ellipsis"> ... </span>');
	        $hidden.hide(100);
	    }
	});
}