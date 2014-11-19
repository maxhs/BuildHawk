// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function categorySort(categoryIds) {
	console.log('categorySort: '+categoryIds);
	for (index = 0; index < categoryIds.length; ++index) {
	    console.log(categoryIds[index]);
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