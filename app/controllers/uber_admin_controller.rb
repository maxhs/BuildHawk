class UberAdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_user

	def index
		@companies = Company.all
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :index
		end
	end

	def core_checklists
		@checklists = Checklist.where("core = ? and company_id IS NULL",true).sort_by(&:name).compact.uniq
		# puts "core names: #{names}"
		# @checklists = [] 
		# names.each do |n|
		# 	@checklists << Checklist.where("core = ? and name = ? and project_id IS NULL and company_id IS NULL",true,n).first
		# end
		#@checklists = @checklists.sort_by(&:name).compact.uniq
		if request.xhr?
			respond_to do |format|
				format.js
			end
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
		@companies = Company.all
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
		@users = User.all
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
		end
	end

end
