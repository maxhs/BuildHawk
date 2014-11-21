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

function editSetup(projectId){
	$(".for-select-2").select2();
	$('#top-nav a').removeClass('current-page');
	$('.nav-edit a,#'+projectId+'-link').addClass('current-page');
	$("#project_core").change(function() {
	    if(this.checked) {
	    	$('#project_core').after('<span id="core-warning"> WARNING: This will make the project visible to all users</span>');
	    } else {
	    	$('#core-warning').fadeOut(200,function(){
	    		$(this).remove();
	    	});
	    }
	});
}