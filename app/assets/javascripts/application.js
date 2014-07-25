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
//= require jquery.easing
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
function setupWindow(){
    var notice = document.getElementById("notice");
    var alert = document.getElementById("alert");
    if (notice.textContent.length > 0) {
        $('#notice').delay(500).fadeIn("normal", function() {
            $(this).delay(3300).fadeOut(function(){$(this).text("");});
        });
    }
    if (alert.textContent.length > 0) {
        $("#alert").delay(500).fadeIn("normal", function() {
            $(this).delay(3300).fadeOut(function(){$(this).text("");});
        });
    }
}