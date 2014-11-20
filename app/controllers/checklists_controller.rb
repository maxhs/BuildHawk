class ChecklistsController < AppController
	before_filter :authenticate_user!
	def index
		@checklists = current_user.company.checklists
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def show
		@checklist = Checklist.find params[:id]
	end

	def new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create

	end

	def load_items
		@phase = Phase.find params[:id]
		@checklist = @phase.checklist
		@project = @checklist.project
		@categories = @phase.categories
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			if @project
				redirect_to checklist_project_path
			else
				redirect_to editor_admin_index_path(cid: @checklist.id)
			end
		end
	end

	def update
		@checklist = Checklist.find params[:id]
		@checklist.update_attributes params[:checklist]
		@company = current_user.company
		@checklists = @company.checklists
		
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			if current_user.uber_admin?
				redirect_to core_checklists_uber_admin_index_path
			else
				redirect_to checklists_admin_index_path
			end
		end
	end


	def search_items
		@project = Project.find params[:project_id]
		if params[:search] && params[:search].length > 0
			search_term = "%#{params[:search]}%" 
			initial = ChecklistItem.search do
				fulltext search_term
				with :checklist_id, params[:id]
			end
			@items = initial.results.uniq
			@prompt = "No search results"
			if request.xhr?
				respond_to do |format|
					format.js
				end
			end
		else 
			@checklist = @project.checklist
			render "projects/checklist"
		end
	end

	def new_checklist_item
		@checklist_item = ChecklistItem.new

		@category = Category.find params[:category_id]
		@phase = @category.phase
		@checklist = @phase.checklist
		@phase = @phase.name
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new_checklist_item
		end
	end

	def create_checklist_item

		@item = ChecklistItem.create params[:checklist_item]
		@category = @item.category
		@checklist = @item.checklist

		if request.xhr?
			respond_to do |format|
				format.js {render template:"admin/create_checklist_item"} 
			end
		else
			render "admin/editor"
		end
	end

	def category
		@category = Category.find params[:category_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :category
		end
	end

	def update_category
		@category = Category.find params[:category_id]
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
		unless @checklist.project.nil?
			@project = @checklist.project
			@projects = @checklist.project.company.projects
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
					format.js { render :template => "admin/editor" }
				end
			else
				render "admin/editor"
			end
		end
	end

	def destroy_category
		@category = Category.find params[:category_id]
		@checklist = Checklist.find params[:id]
		@project = @checklist.project
		if @category.destroy && request.xhr?
			if @project
				respond_to do |format|
					format.js { render :template => "projects/checklist"}
				end
			else
				respond_to do |format|
					format.js { render :template => "admin/editor"}
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
	
	def order_phases
		@checklist = Checklist.find params[:id]
		@project = @checklist.project unless @checklist.project.nil?
		params[:phase].each_with_index do |p,i|
			@phase = Phase.find p
			@phase.update_attribute :order_index, i
		end
		respond_to do |format|
			format.js  { render :template => "checklists/reorder"}
		end
	end

	def order_categories
		@phase = Phase.find params[:id]
		@project = @phase.checklist.project unless @phase.checklist.project.nil?
		params[:category].each_with_index do |p,i|
			category = Category.find p
			category.update_attribute :order_index, i
		end
		respond_to do |format|
			format.js  { render :template => "checklists/reorder"}
		end 
	end

	def order_items
		category = Category.find params[:id]
		@project = category.phase.checklist.project
		params[:item].each_with_index do |item,i|
			@item = ChecklistItem.find item
			@item.update_attribute :order_index, i
		end
		respond_to do |format|
			format.js { render :template => "checklists/reorder"}
		end
	end

	def destroy
		list = Checklist.find params[:id]
		@checklist_id = params[:id] if list
		@core = true if list.core
		list.destroy
		
		@checklist = Checklist.new
		if @core
			@checklists = Checklist.where(:core => true)
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				redirect to core_checklists_uber_admin_index_path
			end
		else
			@company = Company.find params[:company_id]
			@checklists = @company.checklists
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				render :checklists
			end
		end
		
	end
end
