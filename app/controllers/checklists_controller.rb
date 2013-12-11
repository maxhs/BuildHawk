class ChecklistsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@checklists = current_user.company.checklists
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def show
		@checklist = Checklist.find params[:id]
	end

	def new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create

	end

	def update
		puts "checklist update params: #{params}"
		@checklist = Checklist.find params[:id]
		@checklist.update_attributes params[:checklist]
		@company = current_user.company
		@checklists = @company.checklists
		redirect_to checklists_admin_index_path
		# if request.xhr?
		# 	respond_to do |format|
		# 		format.js { render :template => "admin/checklists"}
		# 	end
		# else
		# 	render 'admin/checklists'
		# end
	end
	
end
