function dismissReport(projectId){
	$('.panel').removeClass('panel');
	$('.active-report').removeClass('active-report');
	$('.faded').removeClass('faded');
	$('#report.focus').css('left','101%');
	$("html, body").animate({ scrollTop: 0 }, 230 ,function(){
		$('#report.focus').html('');
	});

	if (history && history.pushState){
	    history.pushState(null, null, '/reports?p='+projectId);
	    $(window).bind("popstate", function(){
	      $.getScript(location.href);
	    });
	}
}

function reportSetup() {
	$('#remove').click(function(){
		$('#search').val('');
		$('#reports-search').submit();
	});
}

function newReport(latitude,longitude,projectId) {
	$('#dp').datepicker().on('changeDate', function(ev){
	    $('#dp').datepicker('hide');
	    reloadWeather(latitude, longitude, ev.date.getTime());
	});
	
	$('#report-add').click(function(){
		if ($(this).val().length > 0) {
			$(this).trigger('submit.rails');
		} else {
			showAlert("Please ensure that you've set a date for this report.");
		}
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

	$('#dismiss-report').click(function(){
		dismissReport(projectId);
	});
}

function reloadWeather(latitude, longitude, date){
	//console.log('reload weather '+date);
	if (!date){
		date = $("#dp").datepicker('getDate').getTime();
	}
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
      		$('#reload-weather').fadeOut(230,function(){
      			$(this).remove();
      		});
        },
      	error:function(data) {
      		showAlert("Something went wrong while trying to load the weather for this report. Please try again soon.");
        }
    })
}

function editReport(latitude,longitude,projectId) {
	$('#dp').datepicker().on('changeDate', function(e){
		$('#dp').datepicker('hide');
	    reloadWeather(latitude, longitude, e.date.getTime());
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
		$(this).parent().parent().fadeOut(230,function(){
			$(this).remove();
		});
	});
	$('#report-save').click(function(){
		if ($(this).val().length > 0) {
			$(this).trigger('submit.rails');
		} else {
			showAlert("Please ensure that you've set a date for this report.");
		}
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
	$('#dismiss-report').click(function(){
		dismissReport(projectId);
	});
}