NProgress.configure({
  showSpinner: false,
  ease: 'easeInOut',
  speed: 400
});

$(document).ready(function() {
  return $(".splash-image").hover((function() {
    $(this).find("p").css({
      color: "#111111",
      WebkitTransition: "color .25s ease-in-out",
      MozTransition: "color .25s ease-in-out",
      MsTransition: "color .25s ease-in-out",
      OTransition: "color .25s ease-in-out",
      transition: "color .25s ease-in-out"
    });
    return $(this).find("span.first").css("opacity", "0");
  }), function() {
    $(this).find("p").css("color", "#666");
    return $(this).find("span.first").css("opacity", "1");
  });
});