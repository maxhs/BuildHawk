class AdminController < ApplicationController
	before_filter :authenticate_user!

	def index
		@core_checklist = Checklist.where(:core => true).last
		@users = current_user.company.users
	end

	def show
		render :checklists
	end

	def edit_item

	end

	def users
		@users = current_user.company.users
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

	def create_user
		@user = current_user.company.users.create params[:user]
		if @user.save & request.xhr?
			@response_message = "Please make sure you've included first name, last name, email and password".html_safe
			respond_to do |format|
				format.js { render :template => "incorrect" }
			end
		elsif @user.save
			flash[:notice] = "User created"
			redirect_to users_admin_index_path
		else
			flash[:notice] = "Unable to create user. Please make sure the form is complete."
			render :new_user
		end
	end

	def delete_user
		@user = User.find params[:id]
		@user.destroy
		redirect_to users_admin_index_path
	end

	def reports

	end

	def checklists
		@checklists = current_user.company.checklists.flatten
	end

	def editor
		@checklist = Checklist.find params[:checklist_id]
	end

	def item_editor
		@item = ChecklistItem.find params[:item_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :item_editor
		end
	end

	def update_item

	end

	def create_template
		@company = Company.find params[:company_id]
		@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}, :except => :core
		@checklist.update_attributes :name => "New Checklist Template", :company_id => @company.id, :core => false
		@checklists = @company.checklists
		redirect_to checklists_admin_index_path
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
			@checklist =  list.dup :include => [:company, {:categories => {:subcategories => :checklist_items}}], :except => {:categories => {:subcategories => {:checklist_items => :status}}}
			@checklist.save
			params[:project].delete(:checklist)
		else 
			@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}, :except => {:categories => {:subcategories => {:checklist_items => :status}}}
			@checklist.save
		end
		@project = Project.create params[:project]
		@project.checklist = @checklist
		if @project.save && request.xhr?
			respond_to do |format|
				format.js
			end
		elsif @project.save
			redirect_to admin_index_path
		else
			@response_message = "Please make sure you've completed the form before submitting".html_safe
			respond_to do |format|
				format.js { render :template => "incorrect" }
			end
		end
	end

	def billing
		@company = current_user.company
	end

	def update_billing
	
	end

end