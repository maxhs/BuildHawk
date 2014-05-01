function sidebarSetup(){
	$('#archived-projects-button').on('click',function(){
		if ($('.projects.archived').css('display') === "none"){
			$('.projects.archived').fadeIn(230);
		} else {
			$('.projects.archived').fadeOut(230);
		}
	});
}

function newProjectSetup(){
	console.log('new project setup');
	$('.new_project').submit(function(){
		$('#alert').text("Creating your project. This may take a few moments.").fadeIn(500);
	});
}