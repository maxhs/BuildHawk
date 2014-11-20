class CategoriesController < AppController
	before_filter :authenticate_user!

	def new
		@phase = Phase.find params[:phase_id]
		@checklist = @phase.checklist
		@project = @checklist.project
		@category = @phase.categories.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			if @project
				render "projects/checklist"
			else
				render "admin/editor"
			end
		end
	end

	def create 
		@category = Category.create params[:category]
		@category.move_to_bottom
		@checklist = @category.phase.checklist
		@project = @checklist.project
		@projects = @project.company.projects if @checklist.project
	end

	def update
		@category = Category.find params[:id]
		if params[:category][:milestone_date].present?
			datetime = Date.strptime(params[:category][:milestone_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@category.update_attribute :milestone_date, datetime
		else
			@category.update_attribute :milestone_date, nil
		end
		
		if params[:category][:completed_date].present?
			datetime = Date.strptime(params[:category][:completed_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@category.update_attribute :completed_date, datetime
		else
			@category.update_attribute :completed_date, nil
		end
		
		if params[:category][:name].present?
			@category.update_attribute :name, params[:category][:name]
		end

		@checklist = @category.phase.checklist
		if @checklist.project
			@project = @checklist.project
			@projects = @project.company.projects if @project.company
			if request.xhr?
			 	respond_to do |format|
			 		format.js { render :template => "projects/checklist" }
			 	end
			else
			 	redirect_to checklist_project_path(@project)
			end
		else 
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				render "admin/editor"
			end
		end
	end

	def edit
		@category = Category.find params[:id]
		@project = @category.phase.checklist.project
		@projects = @project.company.projects if @project
	end

	def destroy
		@category = Category.find params[:id]
		@category_id = @category.id
		@checklist = @category.phase.checklist
		@project = @checklist.project
		if @category.destroy && request.xhr?
			if @project
				respond_to do |format|
					format.js { render :template => "projects/checklist"}
				end
			else
				respond_to do |format|
					format.js
				end
			end
		else
			if @project
				redirect_to checklist_project_path(@project)
			else 
				render "admin/editor"
			end
		end
	end

end
