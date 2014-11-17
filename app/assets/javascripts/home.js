function homeSlideshow(){
    var lspace = '0%';
    var offscreen = "-200%";
    var transition = 7000;    
    var fade,fade1,fade2,fade3;

    fade = function() {
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

function splash(){
  $('a').click(function(){
    $('html, body').animate({
        scrollTop: $( $.attr(this, 'href') ).offset().top
    }, 500);
    return false;
  });
}