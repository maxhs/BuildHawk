class Api::V1::PhotosController < Api::V1::ApiController

    def update

    end

    def show
    	project = Project.find params[:id]
    	photos = project.photos
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => photos, :root => :photos}
      	end
    end

end
