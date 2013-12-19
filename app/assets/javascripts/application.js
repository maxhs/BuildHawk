// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery_nested_form
//= require bootstrap
//= require jquery.remotipart
//= require shadowbox
//= require_tree .

if (history && history.pushState){
    $(function(){
        $('body').on('click', 'a',function(e){
            if ($(e.target).is('.shadow-photo, .documents-photo, .delete-checklist-link, .no-link, #clear-critical-date')) {
            
            } else {
                history.pushState(null, null, this.href);
            }
        });
        $(window).bind("popstate", function(){
          $.getScript(location.href);
        });
    });
}

$(document).ready(function(){
    var width = $(window).width()
    $('#alert,#notice').css("left",width/4);

    if ($('#notice').text().length !== 0) {
        $('#notice').css({}).delay(500).fadeIn("normal", function() {
            $(this).delay(4000).fadeOut();
        });
    }

  if ($("#alert").text().length !== 0) {
    $("#alert").css({}).delay(500).fadeIn("normal", function() {
      $(this).delay(4000).fadeOut();
    });
  }
});