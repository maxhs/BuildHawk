class ProjectGroupsController < AppController
	before_filter :authenticate_user!
	
	def new
		@project_group = ProjectGroup.new
	end

	def create
		@company = current_user.company
		params[:project_group][:company_id] = @company.id
		@project_group = ProjectGroup.create params[:project_group]
		@project_groups = @company.project_groups
		@project = Project.find params[:project_id] if params[:project_id]
	end

	def edit
		@project_group = ProjectGroup.find params[:id]
	end

	def update
		@project_group = ProjectGroup.find params[:id]
		@project_group.update_attributes params[:project_group]
	end

	def destroy
		project_group = ProjectGroup.find params[:id]
		project_group.projects.each do |p|
			p.update_attribute :project_group_id, nil
		end
		@project_group_id = project_group.id
		project_group.destroy
		company = current_user.company
		@project_groups = company.project_groups
	end
end
