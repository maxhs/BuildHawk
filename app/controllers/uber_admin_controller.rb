class UberAdminController < ApplicationController

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

	def core_checklist
		@checklist = Checklist.new
		core_checklist = Checklist.where(:core => true).last
		if core_checklist
			@items = core_checklist.categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
		end
	end

	def upload_template
		Checklist.import(params[:checklist][:file])
		redirect_to uber_admin_index_path
	end

	def import_checklist
		Checklist.import(params[:file])
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

	def users
		@users = User.all
	end

end
