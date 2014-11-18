function dismissReport(){
	$('.reports-panel').removeClass('reports-panel');
	$('.active-report').removeClass('active-report');
	$('#report-focus').css('left','100%');
	$('.faded').removeClass('faded');
	$("html, body").animate({ scrollTop: 0 }, 300);
}

function newReport() {
	picker = $("#dp").datepicker();
	$('#dp').datepicker().on('changeDate', function(){
	    $('#dp').datepicker('hide');
	});
	$('#dp').datepicker().on('select', function(){
	    console.log('you got it!');
	    assignDate(picker.get('select'));
	});
	$('#report-add').click(function(){
		console.log('adding a report');
		$(this).trigger('submit.rails');
	});

	$('#dismiss-report').click(function(){
		dismissReport();
	});
	$('#report_type').select2();
	$('#subs-select').select2({
		placeholder: "Add the companies/subcontractors present"
	});
	$('#subs-select').on("select2-selecting", function(e) { 
	   $('#subs-select').after('<div><input class="report-personnel-input" id="report_companies_'+e.val+'" name="report_companies['+e.val+']" placeholder="0" type="text"><span style="padding-left:1em;">'+ e.choice.text +'</span></div>')
	});

	$('#users-select').select2({
		placeholder: "Select the personnel present"
	});
	$('#users-select').on("select2-selecting", function(e) { 
	   $('#users-select').after('<div><input class="report-personnel-input" id="report_user_ids_'+e.val+'" name="report_users['+e.val+']" placeholder="0" type="text"><span style="padding-left:1em;">'+ e.choice.text +'</span></div>')
	});
}

function assignDate(selected){
	console.log('assign date '+selected);
}