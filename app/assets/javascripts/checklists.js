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

function checklistItem(){
	$("#dp").datepicker();
	$('#dp').datepicker().on('changeDate', function(){
	    $('#dp').datepicker('hide');
	});
	Shadowbox.clearCache();
    Shadowbox.setup(".shadow-photo", {});
    $('#clear-critical-date').click(function(){
    	$('#dp').val('');
    });
}

function dismissChecklistItem(){
	$('.checklist-panel').removeClass('checklist-panel');
	$('.active-item').removeClass('active-item');
	$('#checklist-focus').css({'left':"100%",'top':'0'});
}