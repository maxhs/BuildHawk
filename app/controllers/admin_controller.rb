class AdminController < ApplicationController
	before_filter :authenticate_user!

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
      	company = Company.find params[:company_id]
      	checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}
      	checklist.core = false
      	checklist.name = "New Checklist Template"
      	checklist.company_id = company.id
      	checklist.save
      	
      	@checklists = company.checklists
		@response_message = "Done creating checklist template."
		if request.xhr?
			respond_to do |format|
				format.js {render :template => "admin/checklists"}
			end
		else
			render :checklists
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
		@checklist = Checklist.new
		if params[:project][:checklist].present?
			list = Checklist.find_by(name: params[:project][:checklist])
			params[:project].delete(:checklist)
			#Resque.enqueue(CreateProject,params[:project],list.id)
		else 
			#Resque.enqueue(CreateProject,params[:project],nil)
			@checklist.save
		end
  		if list
  			@checklist = list.dup :include => [:company, {:categories => {:subcategories => :checklist_items}}], :except => {:categories => {:subcategories => {:checklist_items => :status}}}
  			@checklist.save
  		else 
  			@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}, :except => {:categories => {:subcategories => {:checklist_items => :status}}}
  			@checklist.save
  		end
  		@project = Project.create params[:project]
  		@project.checklist = @checklist
		@projects = @project.company.projects

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			flash[:notice] = "Done creating project."
			redirect_to admin_index_path
		end
	end

	def billing
		@company = current_user.company
	end

	def update_billing
	
	end

end