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
//= require jquery_nested_form
//= require jquery.ui.progressbar
//= require jquery.ui.sortable
//= require jquery.ui.autocomplete
//= require bootstrap
//= require dropzone
//= require jquery.remotipart
//= require nprogress
//= require nprogress-ajax
//= require shadowbox
//= require turbolinks
//= require_tree .

if (history && history.pushState){
    $(function(){
        $('body').on('click', 'a',function(e){
            if ($(e.target).is('.remote, .shadow-photo, .documents-photo, .delete-checklist-link, .delete-link, #clear-critical-date')) {

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
    $('#alert,#notice').css("left",width/10);

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

function setupWindow() {
    var width = $(window).width()
    $('#alert,#notice').css("left",width/4);

    if ($('#notice').text().length) {
        $($('#notice')).fadeIn(400, function() {
            $(this).delay(2500).fadeOut();
        });
    } else if ($('#alert').text().length) {
        $($('#alert')).fadeIn(400, function() {
            $(this).delay(2500).fadeOut();
        });
    }
}