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
	$('.new_checklist').on('change',function(){
		$(this).submit();
		$('#alert').css({'color':'#fff','background':'#cc0000'}).text("Uploading a new core checklist. This may take a few moments.").fadeIn(500).delay(4000).fadeOut(500, function(){
			$(this).css({'color':'#000','background':'#fff'}).text("");
		});
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
	$('#export-checklist-item').on('click',function(){
		if (!$('#export-checklist-modal').length > 0){
			$('#item-container').prepend('<%= j render partial:"checklist_item_export", locals: {:item => item} %>');
		}

		$('body').append('<div class="modal-backdrop in"></div>');
		$('#export-checklist-modal').animate({"left":"25%",'opacity':'1'},300);
		$('#cancel-checklist-modal,.modal-backdrop.in').on('click',function(){
			$('#export-checklist-modal').animate({"left":"100%",'opacity':'0'},300);
			$('.modal-backdrop.in').fadeOut(300,function(){
				$(this).remove();
			});
		});
	});
}