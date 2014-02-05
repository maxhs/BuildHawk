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
		@project = photo.project

		@photo_id = params[:id]
		photo.destroy
		@photos = @project.photos.where(:source => "Documents").sort_by(&:created_date).reverse
		@p = @photos.first if @photos && @photos.count
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to document_photos_project_path(@project)
		end
	end

	def update
		@photo = Photo.find params[:id]
		@photo.update_attributes params[:photo]
		if @photo.save && request.xhr?
			respond_to do |format|
				format.js
			end
		elsif @photo.save 
			render :json => {:success => true}
		else 
			render :json => {:success => false}
		end
	end
end
