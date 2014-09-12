class Api::V3::PhotosController < Api::V3::ApiController

    def create
        ## android ##
        if params[:file]
            photo = Photo.new(image: params[:file])
            if params[:file].original_filename
                photo.name = params[:file].original_filename
                photo.save
            end
            params[:photo][:mobile] = true
            photo.update_attributes params[:photo]
        else
        ## ios ##
            photo = Photo.create params[:photo]
        end

        if photo.task
            respond_to do |format|
                format.json { render_for_api :worklist, json: photo.task, root: :task}
            end
        elsif photo.report
            respond_to do |format|
                format.json { render_for_api :reports, json: photo.report, root: :report}
            end
        else
            render json:{photo:photo}
        end
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
