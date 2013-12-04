class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_project

	autocomplete :checklist_item, :body

	def new
		@project = Project.new
		@users = current_user.company.users
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create
		@company = current_user.company
		@project = @company.projects.create params[:project]
		redirect_to admin_index_path
	end

	def index
		@projects = current_user.company.projects if current_user.company

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def show
		@projects = current_user.company.projects if current_user.company
		@checklist = @project.checklist
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :show
		end
	end

	def edit
		@project = Project.find params[:id]
		unless @project.address
			@project.build_address
		end
		@users = current_user.company.users
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :edit
		end
	end

	def update
		if params[:project][:checklist].present?
			checklist = Checklist.find_by(name: params[:project][:checklist])
			@project.update_attribute :checklist_id, checklist.id
			params[:project].delete(:checklist)
		end
		@project = Project.find params[:id]
		@project.update_attributes params[:project]
		@projects = current_user.company.projects
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			flash[:notice] = "Project updated"
			render :edit
		end
	end 

	def destroy
		@project.destroy
		redirect_to projects_path
	end

	def checklist
		#@items = @project.checklist.categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
		@checklist = @project.checklist
	end     

	def checklist_item
		@checklist_item = ChecklistItem.find params[:id]
	end

	def punchlists
		@punchlist = @project.punchlists.first
	end

	def reports
		@reports = @project.reports
	end

	def photos
		@photos = @project.photos
	end	

	def new_punchlist_item
		@punchlist_item = PunchlistItem.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			redirect_to punchlists_project_path(@project)
		end
	end

	def punchlist_item
		@project = Project.find params[:project_id]
		if @project.punchlists.count == 0
			@punchlist = @project.punchlists.create
		else
			@punchlist = @project.punchlists.first
		end
		@punchlist_item = @punchlist.punchlist_items.create params[:punchlist_item]
		redirect_to project_path(@project)
	end

	def edit_punchlist_item
		@punchlist_item = PunchlistItem.find params[:id]
	end

	def update_punchlist_item
		@punchlist_item = PunchlistItem.find params[:id]
		@punchlist_item.update_attributes params[:punchlist_item]
	end

	def new_photo
		@new_photo = Photo.new
	end

	def photo
		@photo = Photo.create params[:photo]
		@photo.update_attributes :company_id => params[:company_id],:project_id => params[:project_id],:user_id => params[:user_id]
		redirect_to photos_project_path(@project)
	end

	private

	def find_project
		@project = Project.find params[:id] if params[:id]
		@company = current_user.company
		@projects = @company.projects
		@users = current_user.company.users
	end

end
