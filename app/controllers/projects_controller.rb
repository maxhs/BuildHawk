class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	
	def index
		@projects = current_user.company.projects
	end

	def show
		@project = Project.find params[:id]
	end

	def edit

	end

	def update
		@project.update_attributes params[:project]
	end
end
