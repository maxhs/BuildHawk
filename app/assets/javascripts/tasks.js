function dismissTask() {
	$('.tasks-panel').removeClass('tasks-panel');
	$('.active-task').removeClass('active-task');
	$('.faded').removeClass('faded');
	$('#task-focus').css({'left':"100%",'top':'0'});
	$("html, body").delay(200).animate({ scrollTop: 0 }, 200);
}