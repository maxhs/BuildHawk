class FoldersController < ApplicationController
	before_filter :authenticate_user!
	def create
		@folder = Folder.create params[:folder]
		@project = @folder.project 
		@photos = @project.photos.where(:source => "Documents").sort_by(&:created_date).reverse
		@folders = @project.folders
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to document_photos_project_path(@project)
		end	
	end

	def edit
		@folder = Folder.find params[:id]
	end

	def update
		@folder = Folder.find params[:id]
		@folder.update_attributes params[:folder]
		@project = @folder.project
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to document_photos_project_path(@project)
		end
	end

	def destroy
		folder = Folder.find params[:id]
		@project = folder.project
		@folder_id = params[:id]
		folder.destroy
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to document_photos_project_path(@project)
		end
	end

end
