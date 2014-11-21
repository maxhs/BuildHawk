function setupDropzone (folderId){
	$('#fid-'+folderId+' form').dropzone({
		init: function () {
		    this.on("complete", function (file) {
		      	if (this.getUploadingFiles().length === 0 && this.getQueuedFiles().length === 0) {
		        	location.reload();
		      	}
			});
			this.on("addedfile",function(){
				$('#fid-'+folderId+'-add-document .dz-message').text("Uploading...");
			});
		}
	});
}