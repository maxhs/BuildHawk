function datetimepickers(){
	$("#dp,#dp-completed").datepicker();		
	$('#clear-critical-date').on('click',function(){
		$('#dp').val('');
	});
	$('#clear-completed-date').on('click',function(){
		$('#dp-completed').val('');
	});
}

function checklistSetup(){
	$('#top-nav a').removeClass('current-page');
	$('.nav-checklists a,#nav-projects a,#<%=@project.id%>-link').addClass('current-page');

	$('.phase-link').click(function(e){
		if ($(this).hasClass('expanded')){
			var pid = $(this).data('phase');
			$(this).removeClass('expanded');
			$('#'+pid+'-items').hide(230,function(){
				$('#phase-'+pid+' .disclosure').replaceWith('<i class="fa fa-minus disclosure"></i>');
			});
			$('#'+pid+'-items').removeClass('revealed');

			return false;
		} else {
			$(this).addClass('expanded');
		}
	});
}

function projectChecklistSetup(){
	$(document).on('click',".checklist-item-link",function(){
		$('.active-item').removeClass('active-item');
		$(this).parent().parent().addClass('active-item');
	});
	
	$('#checklist-search-button').click(function(){
		if ($('#checklist-search').css('display') == "none"){
			$('#checklist-search').fadeIn().css('display','table');
		} else {
			$('#checklist-search').fadeOut(230);
		}
	});
	$('#remove').on('click',function(){
		$('#search').val('');
		$('#checklist-search').submit();
	});
}

function coreChecklist(){
	$('.company-template').click(function(){
		showAlert("Creating your template. This may take a few moments. You can refresh to view the checklist's status.");
	});
}

function dismissChecklist(projectId,checklistId){
	$('.panel').removeClass('panel');
	$('.active-item').removeClass('active-item');
	$('#checklist.focus').css('left',"101%");
	setTimeout(function(){$('#checklist.focus').html('')},230);

	if (history && history.pushState && (projectId || checklistId)){
		if (projectId){
			history.pushState(null, null, '/projects/'+projectId+'/checklist');
		} else if (checklistId) {
			history.pushState(null, null, '/admin/editor?cid='+checklistId);
		}
	    $(window).bind("popstate", function(){
	      $.getScript(location.href);
	    });
	}
}

function checklistItem(itemExportPartial, projectId){
	$("#dp").datepicker();
	$('#dp').datepicker().on('changeDate', function(){
	    $('#dp').datepicker('hide');
	});
	Shadowbox.clearCache();
    Shadowbox.setup(".shadow-photo", {});

    $('#floating-save').click(function(){
		$('.edit_checklist_item').trigger('submit.rails');
	});

    $('#clear-critical-date').click(function(){
    	$('#dp').val('');
    });
    $('#dismiss-checklist-item').click(function(){
		dismissChecklist(projectId);
	});

	$('#export-checklist-item').on('click',function(){
		if (!$('#export-checklist-modal').length > 0){
			$('#item-container').prepend(itemExportPartial);
		}

		$('body').append('<div class="modal-backdrop in"></div>');
		$('#export-checklist-modal').animate({"left":"25%",'opacity':'1'},230);
		$('#cancel-checklist-modal,.modal-backdrop.in').on('click',function(){
			$('#export-checklist-modal').animate({"left":"100%",'opacity':'0'},230);
			$('.modal-backdrop.in').fadeOut(230,function(){
				$(this).remove();
			});
		});
	});
}

function checklistSort(checklistId){
	$('#phases').sortable({
		axis: 'y',
		dropOnEmpty:true,
		cursor: 'move',
		items: 'li',
		opacity: 0.4,
		scroll: true,
		stop: function(){
		$.ajax({
		    type: 'post',
		    data: $('#phases').sortable('serialize') + '&id=' + checklistId,
		    dataType: 'script',
		    url: '/checklists/order_phases'})
		}
	});
	$('#phases li:first-child .phase-link').click();
}
