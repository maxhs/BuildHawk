function datetimepickers(){
	$("#dp,#dp-completed").datepicker();		
	$('#clear-critical-date').on('click',function(){
		$('#dp').val('');
	});
	$('#clear-completed-date').on('click',function(){
		$('#dp-completed').val('');
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

function dismissChecklist(projectId){
	$('.panel').removeClass('panel');
	$('.active-item').removeClass('active-item');
	$('#checklist.focus').css('left',"101%");
	setTimeout(function(){$('#checklist.focus').html('')},230);

	if (history && history.pushState && projectId){
	    history.pushState(null, null, '/projects/'+projectId+'/checklist');
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
