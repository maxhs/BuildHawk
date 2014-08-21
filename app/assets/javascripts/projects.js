function sidebarSetup(){
	$('#archived-projects-button').on('click',function(){
		if ($('.projects.archived').css('display') === "none"){
			$('.projects.archived').fadeIn(230);
		} else {
			$('.projects.archived').fadeOut(230);
		}
	});
}

function newProjectSetup(){
	$('.new_project').submit(function(e){
		if ($('#checklist_id').val()) {
			$('#alert').text("Creating your project. This may take a few moments.").fadeIn(500);
		} else {
			$('#alert').html("<span>Please select a checklist. You can create checklist templates <a href='/admin/checklists' id='alert-refresh' style='text-decoration:underline;' data-remote=true >here</a></span>.").fadeIn(200);
			return false;
		}
	});
}

function setupSearch(content){
	$('#dismiss-search').click(function(){
		$('#main').html(content);
	});
}