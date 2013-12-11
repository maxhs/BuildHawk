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
		@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}
		@checklist.update_attributes :name => "New Checklist Template", :company_id => @company.id  
		@checklist.save!
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
		puts "create project params: #{params}"
		@checklist = Checklist.new
		if params[:project][:checklist].present?
			list = Checklist.find_by(name: params[:project][:checklist])
			@checklist =  list.dup :include => [:company, {:categories => {:subcategories => :checklist_items}}], :except => :project_id
			@checklist.save!
			puts "new checklist has #{@checklist.categories.count} categories after save"
			params[:project].delete(:checklist)
		else 
			puts "did not have a checklist in the params"
			@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}
			@checklist.save!
		end
		puts "checklist outside of initial find method: #{@checklist.categories.count} with id: #{@checklist.id}"
		
		@project = Project.create params[:project]
		@project.checklist = @checklist
		#@project.update_attribute :checklist_id, @checklist.id if @checklist
		if @project.save! && request.xhr?
			respond_to do |format|
				format.js
			end
		elsif @project.save!
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