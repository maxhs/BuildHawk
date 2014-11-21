function documentPhotos(){
	$('#main * .navbar-nav > li > a').removeClass('current-page');
	$('.nav-documents a').addClass('current-page');
	$(document).ready(function(){
		Shadowbox.clearCache();
	    Shadowbox.setup(".shadow-photo", {});
	});
}