class ChecklistItemsController < AppController
	before_filter :authenticate_user!
	
	def new
		@item = ChecklistItem.new
		@item_index = params[:item_index]
		@category = Category.find params[:category_id]
		@phase = @category.phase
		@checklist = @phase.checklist
		@project = @checklist.project
		@phase_name = @phase.name
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
		@item = ChecklistItem.create params[:checklist_item]
		@item.move_to_bottom
		@checklist = @item.checklist
		@category = @item.category
		@project = @checklist.project if @checklist.project
		if request.xhr?
			respond_to do |format|
				format.js 
			end
		else
			render :checklist
		end
	end

	def edit
		@item = ChecklistItem.find params[:id]	
		@checklist = @item.category.phase.checklist
		@project = @checklist.project
		@projects = @project.company.projects if @project
		@core = params[:core] if params[:core].present?
	end

	def update
		@item = ChecklistItem.find params[:id]
		if params[:checklist_item][:critical_date].present?
			datetime = Date.strptime(params[:checklist_item][:critical_date].to_s,"%m/%d/%Y").to_datetime + 12.hours
			params[:checklist_item][:critical_date] = datetime
		end
		if params[:checklist_item][:state].present?
			state = params[:checklist_item][:state][1]
			if state == "No state"
				params[:checklist_item][:state] = nil
			else 
				params[:checklist_item][:state] = state
				params[:checklist_item][:completed_by_user_id] = current_user.id if state == "Completed"
			end
		end

		@item.update_attributes params[:checklist_item]
		@item.log_activity(current_user)

		@checklist = @item.category.phase.checklist
		if @checklist.core && @checklist.company_id.nil?
			@items = @checklist.items
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else 
				redirect_to core_checklist_uber_admin_index_path
			end
		elsif @checklist.project_id
			@project = @checklist.project
			unless request.xhr?
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

	def show
		@item = ChecklistItem.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			@checklist = @item.category.phase.checklist
			@project = @checklist.project
			if @project
				render "projects/checklist"
			else
				render "admin/editor"
			end
		end
	end

	def generate
		@item = ChecklistItem.find params[:id]
	end

	def export
		@item = ChecklistItem.find params[:id]
		project = @item.checklist.project
		@recipients = []
		params[:names].each do |r|
			puts "r: #{r}"
			recipient = User.where(:full_name => r).first
			if recipient
				ChecklistMailer.export(recipient.email, @item, project).deliver 
				@recipients << recipient.full_name
			end
		end
		params[:email].split(',').each do |e|
			email = e.strip if e.include?("@")
			if email
				ChecklistMailer.export(e, @item, project).deliver
				@recipients << email
			end
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render checklist_project_path(project)
		end
	end


	def destroy
		checklist_item = ChecklistItem.find params[:id]
		@item_id = params[:id]
		@category = checklist_item.category
		@checklist = @category.phase.checklist
		@project = @checklist.project
		checklist_item.destroy
	end
end
