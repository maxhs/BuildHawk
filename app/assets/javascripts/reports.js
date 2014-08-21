function dismissReport(){
	$('.reports-panel').removeClass('reports-panel');
	$('.active-report').removeClass('active-report');
	$('#report-focus').css('left','100%');
	$('.faded').removeClass('faded');
	$("html, body").animate({ scrollTop: 0 }, 300);
}