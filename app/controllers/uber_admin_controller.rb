class UberAdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_user

	def index
		@companies = Company.all.order('name ASC')
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :index
		end
	end

	def core_checklists
		@checklists = Checklist.where("core = ? and company_id IS NULL and project_id IS NULL",true)

		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end

	def create_blank_template
		@checklist = Checklist.create :core => true, :name => "Blank template"
		phase = @checklist.phases.create :name => "First phase"
		category = phase.categories.create :name => "First category"
		category.checklist_items.create :body => "First item"
		@checklist.phases.map{|p| p.categories.build}
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to core_checklists_uber_admin_index_path
		end
	end

	def upload_template
		Checklist.import(params[:checklist][:file])
		redirect_to core_checklists_uber_admin_index_path
	end

	def import_checklist
		Checklist.import(params[:file])
		redirect_to core_checklists_uber_admin_index_path
	end

	def safety_topics
		@safety_topics = SafetyTopic.where("company_id IS NULL")
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :safety_topics
		end
	end

	def edit_item
		@checklist_item = ChecklistItem.find params[:id]
	end

	def edit_user
		@user = User.find params[:user_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :edit_user
		end
	end

	def update_user
		@user = User.find params[:user_id]
		@user.update_attributes params[:user]
		@users = User.all
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :users
		end
	end

	def destroy_user
		@user = User.find params[:user_id]
		@user.destroy
		@users = User.all
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "uber_admin/users"}
			end
		else
			redirect_to users_uber_admin_index_path
		end
	end

	def show

	end

	def update_item

	end

	def companies
		@companies = Company.all.order('name ASC')
	end

	def edit_company
		@company = Company.find params[:company_id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :edit_company
		end
	end

	def update_company
		@company = Company.find params[:company_id]
		@company.update_attributes params[:company]
		@companies = Company.all
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :companies
		end
	end

	def destroy_company
		@company = Company.find params[:company_id]
		@company.destroy
		@companies = Company.all
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "uber_admin/companies"}
			end
		else
			redirect_to companies_uber_admin_index_path
		end
	end

	def users
		@users = User.all.order('first_name')
	end

	def promo_codes
		@companies = Company.all
		@promo_codes = PromoCode.all
		@new_code = PromoCode.new
	end

	protected

	def find_user
		unless current_user.uber_admin?
			flash[:alert] = "Sorry, you don't have access to that section.".html_safe
			redirect_to projects_path
		else
			@user = current_user
			@projects = @user.project_users.where(:archived => false).map(&:project).compact.uniq
			@company = @user.company
		end
	end

end
