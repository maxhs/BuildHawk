NProgress.configure({
  showSpinner: false,
  ease: 'easeInOut',
  speed: 400
});

function homeSlideshow(){
    console.log('home homeSlideshow');
    var lspace = '0%';
    var offscreen = "-200%";
    var transition = 6000;
    
    var fade,fade1,fade2,fade3,fade4,fade5,restart;


    fade = function() {
        console.log('fade');
      $('#slide-1').animate({'left':offscreen},400);
      $('#slide-2').animate({'left':lspace},400);
      setTimeout(fade1,transition);
    }

    fade1 = function() {
      $('#slide-2').animate({'left':offscreen},400);
      $('#slide-3').animate({'left':lspace},400);
      setTimeout(fade2,transition);
    }
    fade2 = function() {
      $('#slide-3').animate({'left':offscreen},400);
      $('#slide-4').animate({'left':lspace},400);
      setTimeout(fade3,transition);
    }
    fade3 = function() {
      $('#slide-4').animate({'left':offscreen},400);
      $('#slide-1').animate({'left':lspace},400);
      setTimeout(fade,transition);
    }
    setTimeout(fade,transition);
}