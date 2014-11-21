// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function categorySort(phaseId) {
    var selector = '#'+phaseId+'-items';
    $(selector).sortable({
      axis: 'y',
      dropOnEmpty:true,
      cursor: 'move',
      items: 'li',
      opacity: 0.4,
      scroll: true,
      stop: function(){
        $.ajax({
            type: 'post',
            data: $(selector).sortable('serialize') + '&id=' + phaseId,
            dataType: 'script',
            url: '/checklists/order_categories'
        })
      }
    });
}

function category(projectId){
    $('#dismiss-category').click(function(){
        dismissChecklist(projectId);
    });
    $('#floating-save').click(function(){
        $('.edit_category').trigger('submit.rails');
    });
}