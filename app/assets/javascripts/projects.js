function projectDashboard(projectId) {
	$('a').removeClass('current-page');
	$('#'+projectId+'-link, .nav-dashboard.admin a').addClass('current-page');
	Shadowbox.clearCache();
    Shadowbox.setup(".shadow-photo", {});
}

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