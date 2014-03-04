class AdminController < ApplicationController
	before_filter :authenticate_user!
	layout 'admin'	

	def index
		@core_checklist = Checklist.where(:core => true).last
		@checklists = current_user.company.checklists
	end

	def show
		render :checklists
	end

	def edit_item

	end

	def users
		@users = current_user.company.users
		@subs = current_user.company.subs
	end

	def new_user
		@user = User.new
	end

	def create_user
		@user = current_user.company.users.create params[:user]
		@users = current_user.company.users
		@subs = current_user.company.subs
		if @user.save & request.xhr?
			@response_message = "User created".html_safe
			respond_to do |format|
				format.js { render :template => "admin/users" }
			end
		elsif @user.save
			flash[:notice] = "User created"
			redirect_to users_admin_index_path
		elsif request.xhr?
			@response_message = "Unable to create user. Please make sure the form is complete and the passwords match".html_safe
			respond_to do |format|
				format.js { render :template => "admin/incorrect" }
			end
		else
			flash[:notice] = "Unable to create user. Please make sure the form is complete and the passwords match."
			render :new_user
		end
	end

	def edit_user
		@user = User.find params[:id]
	end

	def update_user
		@user = User.find params[:id]
		@user.update_attributes params[:user]
		redirect_to users_admin_index_path
	end

	def new_sub
		@sub = Sub.new
	end

	def create_sub
		@sub = current_user.company.subs.create params[:sub]
		if @sub.save & request.xhr?
			@response_message = "Please make sure you've included a contact".html_safe
			respond_to do |format|
				format.js { render :template => "incorrect" }
			end
		elsif @sub.save
			flash[:notice] = "Sub created"
			redirect_to users_admin_index_path
		else
			flash[:notice] = "Unable to create sub. Please make sure the form is complete."
			redirect_to users_admin_index_path
		end
	end

	def edit_sub
		@sub = Sub.find params[:id]
	end

	def update_sub
		@sub = Sub.find params[:id]
		@sub.update_attributes params[:sub]
		redirect_to users_admin_index_path
	end

	def delete_user
		@user = User.find params[:id]
		@user.destroy
		redirect_to users_admin_index_path
	end

	def delete_sub
		@sub = Sub.find params[:id]
		@sub.destroy
		redirect_to users_admin_index_path
	end

	def reports
		@projects = current_user.company.projects
	end

	def checklists
		@checklists = current_user.company.checklists.flatten
	end

	def editor
		@checklist = Checklist.find params[:checklist_id]
	end

	def create_template
		#Resque.enqueue(CreateTemplate,params[:company_id])
		#@response_message = "Creating checklist template. This may take a few minutes..."
		@company = current_user.company 
		@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}, :except => :core
      	@checklist.update_attributes :name => "New Checklist Template", :company_id => @company.id, :core => false
		@checklists = @company.checklists
		if request.xhr?
			respond_to do |format|
				#format.js {render :template => "admin/background_template"}
				format.js {render template: "admin/checklists"}
			end
		else
			flash[:notice] = @response_message
			redirect_to checklists_admin_index_path
		end
	end

	def delete_checklist
		@checklist = Checklist.find params[:checklist_id]
		@checklist.destroy
		@company = Company.find params[:company_id]
		@checklists = @company.checklists
		if request.xhr?
			respond_to do |format|
				format.js {render :template => "admin/checklists"}
			end
		else
			render :checklists
		end
	end

	def new_project
		@project = Project.new
		@project.build_address
		@project.project_users.build
		@users = current_user.company.users
		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end

	def create_project
		@company = current_user.company
		if params[:project][:checklist].present?
			@checklist = Checklist.where(:name => params[:project][:checklist]).first
			params[:project].delete(:checklist)
		else 
			@checklist = Checklist.where(:core => true).last
		end

		params[:project][:checklist] = @checklist if @checklist

		@project = current_user.company.projects.create params[:project]

		if request.xhr?
			respond_to do |format|
				format.js {render :template => "projects/show"}
			end
		else
			flash[:notice] = @response_message
			redirect_to admin_index_path
		end
	end

	#resque
	# def create_project
	# 	@checklist = Checklist.new
	# 	if params[:project][:checklist].present?
	# 		list = Checklist.find_by(name: params[:project][:checklist])
	# 		params[:project].delete(:checklist)
	# 		Resque.enqueue(CreateProject,params[:project],list.id)
	# 	else 
	# 		Resque.enqueue(CreateProject,params[:project],nil)
	# 		@checklist.save
	# 	end
		
	# 	@response_message = "Creating project. This may take a few minutes..."
	# 	if request.xhr?
	# 		respond_to do |format|
	# 			format.js {render :template => "admin/background_project"}
	# 		end
	# 	else
	# 		flash[:notice] = @response_message
	# 		redirect_to admin_index_path
	# 	end
	# end

	def billing
		@company = current_user.company
	end

	def update_billing
	
	end

	def project_groups
		@company = current_user.company
		@project_groups = @company.project_groups
		@new_group = @company.project_groups.new
	end

end