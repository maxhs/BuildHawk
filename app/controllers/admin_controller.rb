class AdminController < ApplicationController

	def index
		@core_checklist = CoreChecklist.last
	end

	def edit_item

	end

	def users
		@users = current_user.company.users
	end

	def new_user
		@user = User.new
	end

	def create_user
		@user = User.create params[:user]
		redirect_to users_admin_index_path
	end

	def reports

	end

	def checklists

	end

	def new_project
		@project = Project.new
		
		@users = current_user.company.users
		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end

	def create_project
		if params[:project][:checklist].present?
			checklist = Checklist.find_by(name: params[:project][:checklist])
			params[:project].delete(:checklist)
		end
		@project = current_user.company.projects.create params[:project]
		@project.update_attribute :checklist_id, checklist.id
		redirect_to admin_index_path
	end
end