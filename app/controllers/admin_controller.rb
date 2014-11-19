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

	def edit_item

	end

	def personnel
		@company = @user.company
		if @company.customer_id.nil? && current_user.uber_admin?
			@charges = @company.charges
		  	active_projects = @company.projects.where(:active => true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_index_path
		else
			@users = current_user.company.users
			@subcontractors = current_user.company.company_subs			
		end
	end

	def new_user
		@user = User.new
	end

	def edit_user
		@user = User.find params[:id]
	end

	def update_user
		@user = User.find params[:id]
		@user.update_attributes params[:user]
		redirect_to users_admin_index_path
	end

	def new_subcontractor
		@subcontractor = CompanySub.new
		@subcontractor.build_subcontractor
	end

	def create_subcontractor
		company = Company.where(name: params[:company_sub][:subcontractor][:name]).first_or_create
		company_sub = current_user.company.company_subs.where(subcontractor_id: company.id).first_or_create
		company_sub.update_attributes contact_name: params[:company_sub][:contact_name],email: params[:company_sub][:email],phone: params[:company_sub][:phone]
		@users = current_user.company.users
		@subcontractors = current_user.company.company_subs
		
		if company_sub.save
			if request.xhr?
				respond_to do |format|
					format.js {render template:"admin/personnel"}
				end
			else
				redirect_to personnel_admin_index_path, alert: "Subcontractor created"
			end
		else
			redirect_to personnel_admin_index_path, alert: "Unable to create subcontractor. Please make sure the form is complete."
		end
	end

	def edit_subcontractor
		@company_sub = current_user.company.company_subs.where(:subcontractor_id => params[:id]).first
	end

	def update_subcontractor
		@company_sub = current_user.company.company_subs.where(:id => params[:id]).first
		@company_sub.update_attributes params[:company_sub][:subcontractor]
		redirect_to users_admin_index_path
	end

	def delete_user
		@user = User.find params[:id]
		@user.destroy
		redirect_to users_admin_index_path
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
		@checklist = Checklist.find params[:checklist_id]
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
			@checklists = @user.company.checklists.where(:core => true).flatten
			render :checklists
		end
	end

	def create_template
		list = Checklist.find params[:checklist_id]
		@checklist = list.duplicate
		@checklist.update_attribute :company_id, @company.id
		puts "New checklist's company id: #{@checklist.company.id}"
		@checklists = @user.company.checklists.where(:core => true).flatten
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			uber_checklists
			render :checklists
		end
	end

	def remove_template
		@checklist = Checklist.find params[:id]
		@checklist_id = params[:id]
		@checklist.destroy
	end

	def new_project
		@company = @user.company
		@users = current_user.company.users
		@subs = current_user.company.company_subs

		if @company.customer_id.nil?# && current_user.uber_admin?
			@charges = @company.charges
		  	active_projects = @company.projects.where(:active => true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_index_path
		else
			@project = Project.new
			@project.build_address
			@project.project_users.build
			
			@checklists = @user.company.checklists.where(:core => true)
		end
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