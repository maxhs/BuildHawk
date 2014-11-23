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

function projectSetup(projectId) {
	$('#project_user_ids').select2({
		placeholder: "Add personnel to the project"
	});
	$('#project_company_ids').select2({
		placeholder: "Connect companies to the project"
	});
	$(".for-select-2").select2();
	$('.has-tooltip').tooltip();
	$('#top-nav a').removeClass('current-page');
	$('.nav-edit a,#'+projectId+'-link').addClass('current-page');

	$("#project_core").change(function() {
	    if(this.checked) {
	    	$('#core-warning').val('WARNING: This will make the project visible to all users');
	    } else {
    		$('#core-warning').val('');
    	}
	});
}

function setupSearch(content){
	$('#dismiss-search').click(function(){
		$('#main').html(content);
	});
}