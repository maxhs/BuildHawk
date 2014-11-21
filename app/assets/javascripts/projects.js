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
			showAlert("Creating your project. This may take a few moments.");
		} else {
			$('#alert').html("<span>Please select a checklist. You can create checklist templates <a href='/admin/checklists' id='alert-refresh' style='text-decoration:underline;' data-remote=true >here</a></span>.").fadeIn(200);
			return false;
		}
	});

	$('#users-select').select2({
		placeholder: "Add personnel to the project"
	});
	$('#companies-select').select2({
		placeholder: "Connect other companies to the project"
	});
}

function setupSearch(content){
	$('#dismiss-search').click(function(){
		$('#main').html(content);
	});
}