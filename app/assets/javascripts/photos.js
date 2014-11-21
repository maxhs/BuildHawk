function documentPhotos(){
	$('#main * .navbar-nav > li > a').removeClass('current-page');
	$('.nav-documents a').addClass('current-page');
	$(document).ready(function(){
		Shadowbox.clearCache();
	    Shadowbox.setup(".shadow-photo", {});
	});
}

function largeImage(){
	Shadowbox.clearCache();
	Shadowbox.setup(".shadow-photo", {});
	$("#photo_name,#photo_description").focus(function(){
		$('#click-to-edit').fadeOut(170,function(){
			$(this).text('(enter/return to save)');
			$(this).fadeIn(170);
		});
	});
	$("#photo_name,#photo_description").focusout(function(){
		$('#click-to-edit').fadeOut(170,function(){
			$(this).text('(click name to edit)');
			$(this).fadeIn(170);
		});
	});
}