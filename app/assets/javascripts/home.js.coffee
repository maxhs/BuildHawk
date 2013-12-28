# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

NProgress.configure
  showSpinner: false
  ease: 'easeInOut'
  speed: 400
  
$(document).ready ->
  $(".splash-image").hover (->
    $(this).find("p").css
      color: "#111111"
      WebkitTransition: "color .25s ease-in-out"
      MozTransition: "color .25s ease-in-out"
      MsTransition: "color .25s ease-in-out"
      OTransition: "color .25s ease-in-out"
      transition: "color .25s ease-in-out"

    $(this).find("span.first").css "opacity", "0"
  ), ->
    $(this).find("p").css "color", "#666"
    $(this).find("span.first").css "opacity", "1"