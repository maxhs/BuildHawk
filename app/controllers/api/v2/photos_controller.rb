class Api::V2::PhotosController < Api::V1::ApiController

    def update

    end

    def show
    	project = Project.find params[:id]
    	photos = project.photos.where("image_file_name IS NOT NULL").order('created_at DESC')
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => photos, :root => :photos}
      	end
    end

    def destroy
    	@photo = Photo.find params[:id]
    	if @photo.destroy
        	render :json=>{:success=>true}
      	else 
        	render :json=>{:success=>false}
      	end
    end

end
