class ProjectGroupsController < ApplicationController
	before_filter :authenticate_user!
	def create
		@company = current_user.company
		params[:project_group][:company_id] = @company.id
		@project_group = ProjectGroup.create params[:project_group]
		@project_groups = @company.project_groups
	end
end
