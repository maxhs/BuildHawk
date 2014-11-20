function dismissTask(projectId) {
	$('.panel').removeClass('panel');
	$('.active-task').removeClass('active-task');
	$('.faded').removeClass('faded');
	$('#task.focus').css({'left':"101%",'top':'0'});
	$("html, body").delay(200).animate({ scrollTop: 0 }, 230, function(){
		$('#task.focus').html('');
	});

	if (history && history.pushState){
	    history.pushState(null, null, '/projects/'+projectId+'tasklist');
	    $(window).bind("popstate", function(){
	      $.getScript(location.href);
	    });
	}
}

function taskSetup(projectId){
	$('#dismiss-task').click(function(){
		dismissTask(projectId);
	});
	$('#task-save').click(function(){
		$('.new_task, .edit_task').submit();
	});
	$('.assignee-select').select2({
		placeholder: "Select assignees...",
		allowClear: true
	});
	$('#comment-toggle').click(function(){
		if ($('.comment-container').hasClass('collapsed')){
			$(this).text('Comments');
			$('.comment-container').slideDown(130,function(){
				$(this).removeClass('collapsed');
			});
		} else {
			$(this).text('View Comments');
			$('.comment-container').addClass('collapsed');
			$('.comment-container').slideUp(130);
		}
	});
}