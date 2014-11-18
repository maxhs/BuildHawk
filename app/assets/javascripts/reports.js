function dismissReport(){
	$('.reports-panel').removeClass('reports-panel');
	$('.active-report').removeClass('active-report');
	$('#report-focus').css('left','100%');
	$('.faded').removeClass('faded');
	$("html, body").animate({ scrollTop: 0 }, 300);
}

function newReport(latitude,longitude) {
	$("#dp").datepicker();
	$('#dp').datepicker().on('changeDate', function(ev){
	    $('#dp').datepicker('hide');
	    assignDate(latitude, longitude, ev.date.getTime());
	});
	
	$('#report-add').click(function(){
		if ($(this).val().length > 0) {
			$(this).trigger('submit.rails');
		} else {
			$('#alert').text("Please ensure that you've set a date for this report.").fadeIn(200).delay(1700).fadeOut(300, function(){
				$(this).text("");
			});
		}
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

function assignDate(latitude, longitude, date){
	console.log('assign date '+date);
	$.ajax({
      	type: "GET",
     	url: "/reports/weather",
      	data: { latitude: latitude, longitude: longitude, date: date },
      	complete:function(){},
      	success:function(data,textContent, xhr){
      		$('#report_weather').val(data.summary);
      		$('#report_temp').val(data.tempMin+'\u00B0 - '+data.tempMax+'\u00B0');
      		$('#report_humidity').val(data.humidity);
      		$('#report_wind').val(data.windSpeed+' '+data.windBearing);
      		$('#report_precip').val(data.precip);
        },
      	error:function(data) {
      		
        }
    })
}

function editReport(latitude,longitude) {

	$("#dp").datepicker();
	$('#dp').datepicker().on('changeDate', function(ev){
	    $('#dp').datepicker('hide');
	    assignDate(latitude, longitude, ev.date.getTime());
	});
	
	$('.report-topic .title').click(function(){
		var parent = $(this).parent();
		var info = parent.find('.info');
		if (info.css('display') == "none"){
			info.show();
		} else {
			info.hide();
		}
	})

	$('.remove-personnel').click(function(){
		$(this).parent().parent().fadeOut(200,function(){
			$(this).remove();
		});
	});
	$('#report-save').click(function(){
		if ($(this).val().length > 0) {
			$(this).trigger('submit.rails');
		} else {
			$('#alert').text("Please ensure that you've set a date for this report.").fadeIn(200).delay(1700).fadeOut(300, function(){
				$(this).text("");
			});
		}
	});
	$('#dismiss-report').click(function(){
		dismissReport();
	});
	$('#type-select').select2();
	$('#topic-select').select2({
		placeholder: "Select the safety topics covered"
	});
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