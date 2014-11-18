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

function assignDate(latitude, longitude, date){
	console.log('assign date '+date);
	$.ajax({
      	type: "GET",
     	url: "/reports/weather",
      	data: { latitude: latitude, longitude: longitude, date: date },
      	complete:function(){},
      	success:function(data,textContent, xhr){
      		console.log('data '+data.summary);
      		$('#report_weather').val(data.summary);
      		$('#report_temp').val(data.temp);
      		$('#report_humidity').val(data.humidity);
      		$('#report_wind').val(data.wind);
      		$('#report_precip').val(data.precip);
        },
      	error:function(data) {
      		
        }
    })
}