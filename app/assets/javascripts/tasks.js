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

function taskSetup(projectId,exportPartial){
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

	$('#top-nav a').removeClass('current-page');
	$('.nav-tasks a,#'+projectId+'-link').addClass('current-page');
	$('#remove').click(function(){
		$('#search').val('');
		$('#task-search').submit();
	});
	$('#export-tasks').click(function(){
		if (!$('#export-tasklist-modal').length > 0){
			$('#project-tasklist').before(exportPartial);
		}

		var values = [];
		$('.task-checkbox input').each(function(i,obj){
			if (obj.checked) {
				values.push(obj.value);		
			}
		});
		$('body').append('<div class="modal-backdrop in"></div>');

		$('#export-tasklist-modal form').append('<input type="hidden" id="items" name="items" value="'+values+'">');
		$('#export-tasklist-modal').animate({"left":"25%",'opacity':'1'},300);
		$('#cancel-tasklist-modal,.modal-backdrop.in').on('click',function(){
			$('#export-tasklist-modal').animate({"left":"100%",'opacity':'0'},300);
			$('.modal-backdrop.in').fadeOut(300,function(){
				$(this).remove();
			});
		});
	});
}