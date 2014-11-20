// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function categorySort(categoryIds) {
	for (index = 0; index < categoryIds.length; ++index) {
	    var cid = categoryIds[index];
	    $('#items-'+cid).sortable({
	      axis: 'y',
	      dropOnEmpty:true,
	      cursor: 'move',
	      items: 'li',
	      opacity: 0.4,
	      scroll: true,
	      stop: function(){
	        $.ajax({
	            type: 'post',
	            data: $('#items-'+cid).sortable('serialize') + '&id=' + cid,
	            dataType: 'script',
	            url: '/checklists/order_items'
	        })
	      }
	    });
	}
}

function category(projectId){
    $('#dismiss-category').click(function(){
        dismissChecklist(projectId);
    })
}