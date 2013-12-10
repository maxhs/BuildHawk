class AdminController < ApplicationController
	before_filter :authenticate_user!

	def index
		@core_checklist = CoreChecklist.last
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
		if @user.save
			redirect_to users_admin_index_path
		else
			@response_message = "Please make sure you've included first name, last name, email and password".html_safe
			respond_to do |format|
				format.js { render :template => "incorrect" }
			end
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

	def create_template
		@company = Company.find params[:company_id]
		@checklist = @company.checklists.create :name => "New Checklist Template"  
		@checklist.categories << CoreChecklist.last.categories if CoreChecklist.last
		@checklist.save!
		@checklists = @company.checklists
		render :editor
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
		if params[:project][:checklist].present?
			checklist = Checklist.find_by(name: params[:project][:checklist])
			params[:project].delete(:checklist)
		else 
			checklist = Checklist.create
			items = CoreChecklist.last.categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
			checklist.checklist_items << items
		end
		@project = current_user.company.projects.create params[:project]
		@project.update_attribute :checklist_id, checklist.id if checklist
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