class PhasesController < AppController
	before_filter :authenticate_user!
	def new
		@checklist = Checklist.find params[:checklist_id] if params[:checklist_id]
		@phase = @checklist.phases.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render "admin/editor"
		end
	end

	def create 
		@phase = Phase.create params[:phase]
		@phase.move_to_bottom
		@project = @phase.checklist.project
	end

	def show
		if params[:project_id]
			@project = Project.find params[:project_id]
			@projects = @project.company.projects 
		end

		@phase = Phase.find params[:id]
		
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :show
		end

		rescue ActiveRecord::RecordNotFound
		redirect_to projects_path
		flash[:notice] = "Sorry, but that phase has been removed"
	end

	def edit
		@phase = Phase.find params[:id]
	end

	def update
		@phase = Phase.find params[:id]
		if params[:phase][:milestone_date].present?
			datetime = Date.strptime(params[:phase][:milestone_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@phase.update_attribute :milestone_date, datetime
		else
			@phase.update_attribute :milestone_date, nil
		end
		
		if params[:phase][:completed_date].present?
			datetime = Date.strptime(params[:phase][:completed_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			@phase.update_attribute :completed_date, datetime
		else
			@phase.update_attribute :completed_date, nil
		end
		
		if params[:phase][:name].present?
			@phase.update_attribute :name, params[:phase][:name]
		end

		@checklist = @phase.checklist
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

	def destroy
		@phase = Phase.find params[:id]
		@phase_id = @phase.id
		@checklist = @phase.checklist
		@project = @checklist.project
		if @phase.destroy && request.xhr?
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
