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
            if ($(e.target).is('#left-menu-toggle img, #right-menu-toggle, .response-form, #add-feedback-link, #remove-user-image, #logout-link, a.remove, .bookmark-link, .cancel-editing, .edit-contribution, .feature, .delete-link, #more-sentences, #contact-link a, .load-more-stories, #weekly-signup-link')) {
            
            } else {
                history.pushState(null, null, this.href);
            }
        });
        $(window).bind("popstate", function(){
          $.getScript(location.href);
        });
    });
}