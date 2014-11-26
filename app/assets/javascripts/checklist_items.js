function itemSort(categoryId) {
    $('#items-'+categoryId).sortable({
      axis: 'y',
      dropOnEmpty:true,
      cursor: 'move',
      items: 'li',
      opacity: 0.4,
      scroll: true,
      stop: function(){
        $.ajax({
            type: 'post',
            data: $('#items-'+categoryId).sortable('serialize') + '&id=' + categoryId,
            dataType: 'script',
            url: '/checklists/order_items'
        })
      }
    });
}