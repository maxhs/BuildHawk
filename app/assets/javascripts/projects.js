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

	$('.group-header').click(function(){
		var pgId = $(this).data('pg');
		var $projectsDiv = $('#pg-'+pgId+'-projects');
		if ($projectsDiv.hasClass('collapsed')){
			$projectsDiv.removeClass('collapsed');
		} else {
			$projectsDiv.addClass('collapsed');
		}
		
	});

	var groupId, projectId;
	$('#projects, #groups').sortable({
      	axis: 'y',
      	dropOnEmpty:true,
      	cursor: 'move',
      	items: 'li',
      	opacity: 0.6,
      	scroll: true,
      	connectWith: ".sortable-projects",
      	stop: function(e, ui){
      		projectId = ui.item.data('project');
        	groupId = ui.item.parent().data('pg');
            $.ajax({
                type: 'post',
                data: $('#projects, #groups').sortable('serialize') + '&group_id='+groupId + "&project_id="+projectId,
                dataType: 'script',
                url: '/projects/order_projects'})
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
	if (projectId){
		$('.nav-edit a,#'+projectId+'-link').addClass('current-page');
	}
	$("#project_core").change(function() {
	    if($('#project_core').is(":checked")) {
	    	if (projectId){
		    	$('#core-warning').val('WARNING: This will make the project visible to all users');
		    } else {
		    	$('#core-warning').text('WARNING: This will make the project visible to all users');	
		    }
	    } else {
	    	if (projectId){
	    		$('#core-warning').val('').text('');
	    	} else {
	    		$('#core-warning').val('').text('');
	    	}
    	}
	});
}

function setupSearch(content){
	$('#dismiss-search').click(function(){
		$('#main').html(content);
	});
}