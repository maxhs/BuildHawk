function datetimepickers(){
	$("#dp,#dp-completed").datepicker();		
	$('#clear-critical-date').on('click',function(){
		$('#dp').val('');
	});
	$('#clear-completed-date').on('click',function(){
		$('#dp-completed').val('');
	});
}

function coreChecklist(){
	$('.company-template').on('click',function(){
		$('#alert').text("Creating your template. This may take a few moments.").fadeIn(500);
	});
}

function dismissChecklistItem(){
	$('.checklist-panel').removeClass('checklist-panel');
	$('.active-item').removeClass('active-item');
	$('#checklist-focus').css({'left':"100%",'top':'0'});
}

function checklistItem(itemExportPartial){
	$("#dp").datepicker();
	$('#dp').datepicker().on('changeDate', function(){
	    $('#dp').datepicker('hide');
	});
	Shadowbox.clearCache();
    Shadowbox.setup(".shadow-photo", {});
    $('#clear-critical-date').click(function(){
    	$('#dp').val('');
    });
    $('#dismiss-checklist-item').click(function(){
		dismissChecklistItem();
	});

	$('#export-checklist-item').on('click',function(){
		if (!$('#export-checklist-modal').length > 0){
			$('#item-container').prepend(itemExportPartial);
		}

		$('body').append('<div class="modal-backdrop in"></div>');
		$('#export-checklist-modal').animate({"left":"25%",'opacity':'1'},200);
		$('#cancel-checklist-modal,.modal-backdrop.in').on('click',function(){
			$('#export-checklist-modal').animate({"left":"100%",'opacity':'0'},200);
			$('.modal-backdrop.in').fadeOut(200,function(){
				$(this).remove();
			});
		});
	});
}
