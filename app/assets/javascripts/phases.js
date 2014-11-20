// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function phaseSort(checklistId) {
    $('#phases').sortable({
        axis: 'y',
        dropOnEmpty:true,
        cursor: 'move',
        items: 'li',
        opacity: 0.4,
        scroll: true,
        stop: function(){
        $.ajax({
            type: 'post',
            data: $('#phases').sortable('serialize') + '&id=' + checklistId,
            dataType: 'script',
            url: '/checklists/order_phases'})
        }
    });
    //$('#phases li:first-child .phase-link').click();
}

function phase(projectId){
    $('#dismiss-phase').click(function(){
        dismissChecklist(projectId);
    })
}