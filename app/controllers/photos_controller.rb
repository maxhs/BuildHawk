class PhotosController < ApplicationController

	def index
		@project = Project.find params[:project_id]
		@photos = @project.photos
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def destroy
		photo = Photo.find params[:id]
		@photo_id = params[:id]
		photo.destroy
		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end
end
