class Api::V3::PhotosController < Api::V3::ApiController

    def create
        params[:photo][:taken_at] = Time.at(params[:photo][:taken_at].to_i).to_datetime if params[:photo][:taken_at]
        
        ## android ##
        if params[:file]
            photo = Photo.new(image: params[:file])
            if params[:file].original_filename
                photo.name = params[:file].original_filename
                photo.save
            end
            params[:photo][:mobile] = true
            photo.update_attributes params[:photo]
            render json: {photo: photo}
        else
        ## ios ##
            photo = Photo.create params[:photo]
            respond_to do |format|
                format.json { render_for_api :dashboard, json: photo, root: :photo}
            end
        end
    end

    def show
    	project = Project.find params[:id]
    	photos = project.photos.where("image_file_name IS NOT NULL").order('created_at DESC')
    	respond_to do |format|
        	format.json { render_for_api :projects, json: photos, root: :photos}
      	end
    end

    def destroy
    	@photo = Photo.find params[:id]
    	if @photo.destroy
        	render json: {success: true}
      	else 
        	render json: {success: false}
      	end
    end

end
