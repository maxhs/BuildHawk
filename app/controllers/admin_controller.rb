class AdminController < AppController
	before_filter :authenticate_user!
	before_filter :find_user
	require 'stripe'

	def index
		uber_checklists
		@checklists = @user.company.checklists.where(:core => true)
	end

	def show
		render :checklists
	end

	def personnel
		@company = @user.company
		if @company.customer_id.nil? && current_user.uber_admin?
			@charges = @company.charges
		  	active_projects = @company.projects.where(active: true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_index_path
		else
			@users = current_user.company.users
			@subcontractors = current_user.company.company_subs			
		end
		session[:previous_url] = request.original_url
	end

	def safety_topics
		@company = @user.company
		@safety_topics = @company.safety_topics
		@uber_topics = SafetyTopic.where("company_id IS NULL and core = ?",true)
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :safety_topics
		end
	end

	def clone_topic
		topic = SafetyTopic.find params[:id]
		@safety_topic = SafetyTopic.create :title => topic.title, :info => topic.info, :company_id => @user.company.id
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to safety_topics_admin_index_path
		end
	end

	def reports
		@company = @user.company
		if @company.customer_id.nil? && current_user.uber_admin?
			@charges = @company.charges
		  	active_projects = @company.projects.where(:active => true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_index_path
		else
			@projects = current_user.company.projects
		end
	end

	def checklists
		uber_checklists
		@checklists = @user.company.checklists.where(:core => true).flatten
	end

	def editor
		@checklist = Checklist.find params[:cid]
		unless user_signed_in? && (current_user.company.checklists.map(&:id).include?(@checklist.id) || current_user.uber_admin)
			if request.xhr?
				respond_to do |format|
					format.js {render template:"checklists/denied"} 
				end
			else
				redirect_to checklists_admin_index_path, alert:"Sorry, but you don't have access to that checklist.".html_safe
			end
		end
		@project = @checklist.project
	end

	def create_blank_template
		@checklist = Checklist.create :company_id => @user.company.id, :name => params[:name], :core => true
		phase = @checklist.phases.create :name => "Phase"
		category = phase.categories.create :name => "Category"
		category.checklist_items.create :body => "First Item"
		if request.xhr?
			respond_to do |format|
				format.js { render template: "admin/create_template"}
			end
		else
			uber_checklists
			@checklists = @user.company.checklists.where(core: true).flatten
			render :checklists
		end
	end

	def create_template
		list = Checklist.find params[:checklist_id]
		list.duplicate(@company.id,nil)
		@checklist = Checklist.new name: list.name, company_id: @company_id, core: true
		@checklists = @user.company.checklists.where(core: true).flatten
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			uber_checklists
			render :checklists
		end
	end

	def remove_checklist
		checklist = Checklist.find params[:cid]
		checklist.update_column :flagged_for_removal, true
		@checklist_id = params[:cid]
		checklist.background_destroy
	end

	def project_groups
		@company = current_user.company
		@project_groups = @company.project_groups.where("id IS NOT NULL")
	end

	protected

	def uber_checklists
		@uber_checklists = Checklist.where("core = ? and company_id IS NULL and project_id IS NULL",true).flatten.compact.uniq
	end

	def find_user
		unless current_user.any_admin?
			flash[:alert] = "Sorry, you don't have access to that section.".html_safe
			redirect_to projects_path
		else
			if params[:user_id].present?
				@user = User.where(:id => params[:user_id]).first
			else
				@user = current_user
			end
			@projects = @user.project_users.where(:hidden => false).map(&:project).compact.uniq
			@company = @user.company
		end
	end
end