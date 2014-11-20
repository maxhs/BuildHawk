// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function phaseSort(phaseIds) {
    for (index = 0; index < phaseIds.length; ++index) {
        var pid = phaseIds[index];
      	$("#"+pid+"-items").sortable({
            axis: 'y',
            dropOnEmpty:true,
            cursor: 'move',
            items: 'li',
            opacity: 0.4,
            scroll: true,
            stop: function(){
                $.ajax({
                    type: 'post',
                    data: $("#"+pid+"-items").sortable('serialize') + '&id=' + pid,
                    dataType: 'script',
                    url: '/checklists/order_categories'
                })
            }
        });
    }
}