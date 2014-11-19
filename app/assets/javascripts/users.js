function personnelAdmin(){
	$('.fa-info').click(function(e){
		$(this).parent().next('.explanation').fadeIn();
	});
}